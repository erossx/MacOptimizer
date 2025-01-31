import Foundation
import IOKit.ps

class SystemMonitor: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: (total: UInt64, used: UInt64, free: UInt64) = (0, 0, 0)
    @Published var diskUsage: (total: UInt64, used: UInt64, free: UInt64) = (0, 0, 0)
    @Published var batteryInfo: (percentage: Int, isCharging: Bool, cycleCount: Int) = (0, false, 0)
    
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateSystemStats()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateSystemStats() {
        updateCPUUsage()
        updateMemoryUsage()
        updateDiskUsage()
        updateBatteryInfo()
    }
    
    private func updateCPUUsage() {
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let total = Double(cpuInfo.cpu_ticks.0 + cpuInfo.cpu_ticks.1 + cpuInfo.cpu_ticks.2 + cpuInfo.cpu_ticks.3)
            let idle = Double(cpuInfo.cpu_ticks.3)
            self.cpuUsage = ((total - idle) / total) * 100.0
        }
    }
    
    private func updateMemoryUsage() {
        var pageSize: vm_size_t = 0
        let hostPort = mach_host_self()
        host_page_size(hostPort, &pageSize)
        
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let free = UInt64(vmStats.free_count) * UInt64(pageSize)
            let active = UInt64(vmStats.active_count) * UInt64(pageSize)
            let inactive = UInt64(vmStats.inactive_count) * UInt64(pageSize)
            let wired = UInt64(vmStats.wire_count) * UInt64(pageSize)
            
            let used = active + inactive + wired
            let total = used + free
            
            self.memoryUsage = (total: total, used: used, free: free)
        }
    }
    
    private func updateDiskUsage() {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            if let total = values.volumeTotalCapacity,
               let free = values.volumeAvailableCapacity {
                let used = UInt64(total - free)
                self.diskUsage = (total: UInt64(total), used: used, free: UInt64(free))
            }
        } catch {
            Logger.shared.error("디스크 정보 조회 실패: \(error.localizedDescription)")
        }
    }
    
    private func updateBatteryInfo() {
        let powerSource = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSourcesList = IOPSCopyPowerSourcesList(powerSource).takeRetainedValue() as [CFTypeRef]
        
        for powerSource in powerSourcesList {
            if let powerSourceDesc = IOPSGetPowerSourceDescription(powerSource, powerSource).takeUnretainedValue() as? [String: Any] {
                let percentage = powerSourceDesc[kIOPSCurrentCapacityKey] as? Int ?? 0
                let isCharging = powerSourceDesc[kIOPSIsChargingKey] as? Bool ?? false
                let cycleCount = powerSourceDesc[kIOPSCycleCountKey] as? Int ?? 0
                
                self.batteryInfo = (percentage: percentage, isCharging: isCharging, cycleCount: cycleCount)
                break
            }
        }
    }
} 