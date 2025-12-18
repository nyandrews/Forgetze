import Foundation
import SwiftData

@Model
final class Birthday: Identifiable, Validatable {
    var id = UUID()
    var month: Int = 1
    var day: Int = 1
    var year: Int?
    
    init(month: Int, day: Int, year: Int? = nil) {
        self.month = month
        self.day = day
        self.year = year
    }
    
    convenience init(date: Date) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let year = calendar.component(.year, from: date)
        self.init(month: month, day: day, year: year)
    }
    
    var date: Date {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year ?? 2000 // Default year for age calculation
        
        let calendar = Calendar.current
        return calendar.date(from: components) ?? Date()
    }
    
    var age: Int? {
        guard let year = year else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        let currentDay = calendar.component(.day, from: now)
        
        var age = currentYear - year
        
        // If we have full date, be precise
        if month > 0 && day > 0 {
            if currentMonth < month || (currentMonth == month && currentDay < day) {
                age -= 1
            }
        } else if month > 0 {
            // Only month is known
             if currentMonth < month {
                age -= 1
            }
        }
        // If only year is known, just simple subtraction is the best we can do (or assume Jan 1)
        
        return age >= 0 ? age : nil
    }
    
    var hasYear: Bool {
        return year != nil
    }
    
    var displayString: String {
        if month == 0 && day == 0 {
            // Only Year (or nothing)
            return year.map { String($0) } ?? "Unknown"
        } else if month == 0 {
            // Day known, Month unknown? Rare, likely not supported by UI but handle it
            if let year = year {
                return "Day \(day), \(year)"
            }
            return "Day \(day)"
        } else if day == 0 {
            // Month known, Day unknown
            let monthName = Calendar.current.monthSymbols[month - 1]
            if let year = year {
                return "\(monthName), \(year)"
            }
            return monthName
        } else {
            // Full Date
            let monthName = Calendar.current.monthSymbols[month - 1]
            if let year = year {
                return "\(monthName) \(day), \(String(year))"
            } else {
                return "\(monthName) \(day)"
            }
        }
    }
    
    var shortDisplayString: String {
        if month == 0 && day == 0 {
            return year.map { String($0) } ?? "?"
        } else if month == 0 {
            return year.map { "D:\(day) \($0)" } ?? "Day \(day)"
        } else if day == 0 {
            let monthName = Calendar.current.shortMonthSymbols[month - 1]
            return year.map { "\(monthName) \($0)" } ?? monthName
        } else {
            let monthName = Calendar.current.shortMonthSymbols[month - 1]
            if let year = year {
                return "\(monthName) \(day), \(String(year))"
            } else {
                return "\(monthName) \(day)"
            }
        }
    }
    
    var ageDisplayString: String {
        if let age = age {
            return "\(String(age)) years old"
        } else {
            return "Age unknown"
        }
    }
    
    var monthName: String {
        guard month > 0 && month <= 12 else { return "Unknown" }
        return Calendar.current.monthSymbols[month - 1]
    }
    
    var shortMonthName: String {
        guard month > 0 && month <= 12 else { return "?" }
        return Calendar.current.shortMonthSymbols[month - 1]
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        // At least one component must be valid (Year, Month, or Day)
        // Month 0 and Day 0 are now allowed
        let hasContent = (month > 0) || (day > 0) || (year != nil)
        
        // If month is set, it must be valid
        let monthValid = month == 0 || (month >= 1 && month <= 12)
        
        // If day is set, it must be valid (approximate check, can't check variable month lengths perfectly without year)
        let dayValid = day == 0 || (day >= 1 && day <= 31)
        
        return hasContent && monthValid && dayValid
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if month < 0 || month > 12 {
            errors.append("Month must be between 1 and 12")
        }
        
        if day < 0 || day > 31 {
            errors.append("Day must be between 1 and 31")
        }
        
        if month == 0 && day == 0 && year == nil {
             errors.append("At least one birthday component (Year, Month, Day) is required")
        }
        
        return errors
    }
}
