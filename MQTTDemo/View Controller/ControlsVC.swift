//
//  ControlsVC.swift
//  MQTTDemo
//
//  Created by Apipon Siripaisan on 8/2/18.
//  Copyright © 2018 Apipon Siripaisan. All rights reserved.
//

import UIKit
import CoreData

class ControlsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendCrit(_ sender: Any) {
        
        //TabBar().determineAlert(msg: "B8\tPaint\t1\t2018-12-01 10:00:00\tDec 01, 2018\t10:00:00 AM\tResponsible Person\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew")
    }
    
    @IBAction func sendSafe(_ sender: Any) {
        
        //TabBar().determineAlert(msg: "B8\tMachine\t2\tNov 02, 2018\t10:09:28 PM\tResponsible Person\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew")
    }
    @IBAction func ClearAlerts(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
//        let resolvedPredicate = NSPredicate(format: "alertStatus == 'resolved'")
        
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NewAlerts")
//        deleteFetch.predicate = resolvedPredicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
         
        do {
        try context.execute(deleteRequest)
        try context.save()
        } catch {
        print ("There was an error")
        }
        
        
    }
    
    @IBAction func testLogUpdate(_ sender: UIButton) {
        
        (self.tabBarController as? TabBar)?.updateWithLog(msg:
            """
            B8\tPaint\t1\tNov 02, 2018\t10:05:17 PM\tResponsible Person\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew
            B8\tAssembly\t2\tNov 02, 2018\t10:09:23 PM\tResponsible Person\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew
            B8\tMachine\t1\tNov 02, 2018\t10:09:28 PM\tResponsible Person\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew

            """)
             

    }
    
    @IBAction func updateStatus(_ sender: UIButton) {
        
        (self.tabBarController as? TabBar)?.updateWithLog(msg:
            """
            B8\tPaint\t1\tNov 02, 2018\t10:05:17 PM\tResponsible Person\tNov 02, 2018\t11:00 PM\tGear fell on foot\tResolved Date\tResolved Time\tinwork
            B8\tAssembly\t2\tNov 02, 2018\t10:09:23 PM\tPip S\tAccept Date\tAccept Time\tDescription\tResolved Date\tResolved Time\tnew
            B8\tMachine\t1\tNov 02, 2018\t10:09:28 PM\tBrad Person\tAccept Date\tAccept Time\tGear lost\tResolved Date\tResolved Time\tresolved
            B3\tDisassembly\t1\tNov 02, 2018\t10:20:17 PM\tResponsible Person\tNov 02, 2018\t11:00 PM\tGear fell on foot\tResolved Date\tResolved Time\tnew
            B8\tPaint\t1\tNov 02, 2018\t10:50:17 PM\tResponsible Person\tNov 02, 2018\t11:00 PM\tGear fell on foot\tResolved Date\tResolved Time\tnew

            """)
    }
    
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
