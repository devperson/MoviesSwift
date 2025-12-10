  
import Foundation

class iOSPreferencesImplementation: IPreferences
{
    private let lock = NSLock()
    
    func ContainsKey(_ key: String) -> Bool
    {
        return synchronized(lock)
        {
            let userDefaults = GetUserDefaults()
            return userDefaults.object(forKey: key) != nil
        }
    }
    
    func Remove(_ key: String)
    {
        synchronized(lock)
        {
            let userDefaults = GetUserDefaults()
            if userDefaults.object(forKey: key) != nil
            {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    func Clear()
    {
        synchronized(lock)
        {
            let userDefaults = GetUserDefaults()
            if let dict = userDefaults.dictionaryRepresentation() as NSDictionary?
            {
                for (key, _) in dict
                {
                    if let nsKey = key as? NSString
                    {
                        userDefaults.removeObject(forKey: nsKey as String)
                    }
                }
            }
        }
    }
    
    func Set<T>(_ key: String, _ value: T?) throws
    {
        try synchronized(lock)
        {
            let userDefaults = GetUserDefaults()
            
            if let v = value
            {
                switch v
                {
                case let s as String:
                    userDefaults.set(s, forKey: key)
                case let i as Int:
                    userDefaults.set(i, forKey: key)
                case let b as Bool:
                    userDefaults.set(b, forKey: key)
                case let l as Int64:
                    userDefaults.set(String(l), forKey: key)
                case let d as Double:
                    userDefaults.set(d, forKey: key)
                case let f as Float:
                    userDefaults.set(f, forKey: key)                
                default:
                    //userDefaults.set(String(describing: v), forKey: key)
                    throw AppException("Unsupported preference value type: \(type(of: v)) for key: \(key).")
                }
            }
            else
            {
                if userDefaults.object(forKey: key) != nil
                {
                    userDefaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    func Get<T>(_ key: String, defaultValue: T) throws -> T
    {
        var value: Any? = nil
        
        synchronized(lock)
        {
            let userDefaults = GetUserDefaults()
            let stored = userDefaults.object(forKey: key)
            
            guard stored != nil else
            {
                value = defaultValue
                return
            }
            
            switch defaultValue
            {
            case is Int:
                value = userDefaults.integer(forKey: key)
            case is Bool:
                value = userDefaults.bool(forKey: key)
            case is Int64:
                if let str = userDefaults.string(forKey: key)
                {
                    value = Int64(str)
                }
            case is Double:
                value = userDefaults.double(forKey: key)
            case is Float:
                value = userDefaults.float(forKey: key)
            case is String:
                value = userDefaults.string(forKey: key)
            default:
                value = userDefaults.string(forKey: key)
            }
        }
        
        if let value = value as? T
        {
            return value
        }
        else
        {
            throw AppException("Preference value for key \(key) could not be cast to expected type T: \(T.self).")
        }
    }
    
    private func GetUserDefaults() -> UserDefaults
    {
        return UserDefaults.standard
    }
}


