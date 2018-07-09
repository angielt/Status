//
//  HealthViewController.swift
//  Continue
//
//  Created by Angie Ta on 7/6/18.
//  Copyright © 2018 Angie Ta. All rights reserved.
//

import UIKit
import Firebase
import HealthKit


class HealthViewController: UIViewController {
    
    @IBOutlet weak var caloriesConsumed: UILabel!
    @IBOutlet weak var caloriesBurned: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeHealthKit()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func authorizeHealthKit(){
    
        if HKHealthStore.isHealthDataAvailable(){ // request access to healthKit
            
            guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let stepsWalked = HKObjectType.quantityType(forIdentifier: .stepCount),
                let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
                else{
                    print("guard error")
                    return
            }
            
            let infoToRead: Set<HKObjectType> = [
                    dateOfBirth,
                    stepsWalked,
                    flightsClimbed,
                    activeEnergy
                ]
            let infoToWrite: Set<HKSampleType> = []
            
            HKHealthStore().requestAuthorization(toShare: infoToWrite,
                                                 read: infoToRead) { (success, error) in
                                                    
                                                    if error != nil{
                                                        print(error!.localizedDescription)
                                                    }
            }
            
        }
        else{
            print("HealthKit Setup Error");
            return
        }
        
    }

}
