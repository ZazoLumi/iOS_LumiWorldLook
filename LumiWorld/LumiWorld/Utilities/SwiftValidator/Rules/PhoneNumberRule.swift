//
//  PhoneValidation.swift
//
//  Created by Jeff Potter on 11/11/14.
//  Copyright (c) 2014 Byron Mackay. All rights reserved.
//

import Foundation

/**
 `PhoneNumberRule` is a subclass of Rule that defines how a phone number is validated.
 */
public class PhoneNumberRule: RegexRule {
//    let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    
    /// Phone number regular express string to be used in validation.
    //static let regex = "^\\d{10}$"
    //static let regex = "(\\+\\d{2}\\s*(\\(\\d{2}\\))|(\\(\\d{2}\\)))?\\s*\\d{4,5}\\-?\\d{4}"
    static let regex = "([+]?1+[-]?)?+([(]?+([0-9]{3})?+[)]?)?+[-]?+[0-9]{3}+[-]?+[0-9]{4}";

//    let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//    let result =  phoneTest.evaluate(with: value)
    
    /**
     Initializes a `PhoneNumberRule` object. Used to validate that a field has a valid phone number.
     
    - parameter message: Error message that is displayed if validation fails.
    - returns: An initialized `PasswordRule` object, or nil if an object could not be created for some reason that would not result in an exception. 
    */
    public convenience init(message : String = "Enter a valid phone number") {
        self.init(regex: PhoneNumberRule.regex, message : message)
    }
    
}
