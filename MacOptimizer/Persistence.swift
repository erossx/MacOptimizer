//
//  Persistence.swift
//  MacOptimizer
//
//  Created by 이은환 on 2/1/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MacOptimizer")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                Logger.shared.error("Core Data 저장소 로드 실패: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - System Report Methods
    
    func saveSystemReport(cpuUsage: Double, memory: (total: UInt64, used: UInt64, free: UInt64), 
                         disk: (total: UInt64, used: UInt64, free: UInt64), 
                         reportType: String) {
        let context = container.viewContext
        let report = SystemReport(context: context)
        
        report.date = Date()
        report.reportType = reportType
        report.cpuUsage = cpuUsage
        
        report.memoryTotal = Int64(memory.total)
        report.memoryUsed = Int64(memory.used)
        report.memoryFree = Int64(memory.free)
        
        report.diskTotal = Int64(disk.total)
        report.diskUsed = Int64(disk.used)
        report.diskFree = Int64(disk.free)
        
        do {
            try context.save()
            Logger.shared.info("시스템 리포트 저장 완료: \(reportType)")
        } catch {
            Logger.shared.error("시스템 리포트 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func fetchSystemReports(reportType: String) -> [SystemReport] {
        let fetchRequest: NSFetchRequest<SystemReport> = SystemReport.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "reportType == %@", reportType)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SystemReport.date, ascending: false)]
        
        do {
            let reports = try container.viewContext.fetch(fetchRequest)
            return reports
        } catch {
            Logger.shared.error("시스템 리포트 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteOldReports(olderThan date: Date) {
        let fetchRequest: NSFetchRequest<SystemReport> = SystemReport.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date < %@", date as NSDate)
        
        do {
            let reports = try container.viewContext.fetch(fetchRequest)
            for report in reports {
                container.viewContext.delete(report)
            }
            try container.viewContext.save()
            Logger.shared.info("오래된 리포트 삭제 완료")
        } catch {
            Logger.shared.error("오래된 리포트 삭제 실패: \(error.localizedDescription)")
        }
    }
}
