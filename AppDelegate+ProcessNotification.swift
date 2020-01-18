//
//  AppDelegate+ProcessNotification.swift
//  CanaryUser
//
//  Created by Esraa Apady on 11/19/17.
//  Copyright © 2017 Dalia. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func processNotification(notificationInfo: [AnyHashable: Any]?) {
        
        if let notificationInfo = notificationInfo {
            
            // mark notification as sean
//            if let id = notificationInfo["notification_id"] as? String, let notificationId = Int(id) {
//                CanaryApiService().markNotificationAsSeen(notificationId, completion: { (success, error) in
//                    print("PUSH: markNotificationAsSeen \(success)")
//                    return
//                })
//            }
            
            guard let name = notificationInfo["name"] as? String else {
                if let _ = notificationInfo["chat_room"] as? String {
                    self.processChatNotification(notificationInfo)
                    return
                }
                return
            }
            
            if NotificationName.isBuyAndSellNotificaion(name) {
                let adIdStr = notificationInfo["ad_id"] as? String
                let adid = adIdStr == nil ? nil : Int(adIdStr!)
                
                self.handleBuyAndSellNotification(adId: adid)
            } else if name == NotificationName.APP_NOTIFICATION.rawValue {
                self.processAppNotification(notificationInfo: notificationInfo)
            } else if CanaryUserDefaults.getCurrentUser() != nil {
                var tripId: Int?
                if let tripIdStr = notificationInfo["trip_id"] as? String {
                   tripId = Int(tripIdStr)
                }
                if tripId == nil, let tripIdStr = notificationInfo["scheduled_trip_id"] as? String {
                    tripId = Int(tripIdStr)
                }
                self.handleAuthenticatedUserNotification(name: name, tripId: tripId)
            }
        }
    }
    
    func handleBuyAndSellNotification(adId: Int?) {
        let topCotroller = UIApplication.topViewController()
        
        if let adId = adId {
            // show offer details
            topCotroller?.showLoader()
            CanaryApiService().getAdDetails(adId: adId, completion: { (adObj, error) in
                topCotroller?.dismissLoader()
                if let adObj = adObj {
                    let controller = BuyAndSellRouter.instantiateAdDetailsViewController()
                    controller.adObj = adObj
                    let navController = BaseNavigationController(rootViewController: controller)
                    if let tabbarController = topCotroller?.tabBarController {
                        tabbarController.present(navController, animated: true, completion: nil)
                    }else {
                        topCotroller?.present(navController, animated: true, completion: nil)
                        
                    }
                }
            })
        }
    }
    
    func handleAuthenticatedUserNotification(name: String, tripId: Int?) {

       if name == NotificationName.NEW_SCHEDULED_ORDER.rawValue || name == NotificationName.ACCEPT_SCHEDULED_TRIP_PRICE.rawValue {
            if let tripId = tripId {
                let controller =  ShippingServiceRouter.instantiateShippingServicesViewController()
                controller.scheduledItemType = .shipment
                controller.tripId = tripId
                controller.isMine = true
                UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
            }
            
        } else if name == NotificationName.PROPOSE_SCHEDULED_TRIP_PRICE.rawValue || name == NotificationName.START_TRIP.rawValue || name == NotificationName.END_TRIP.rawValue || name == NotificationName.CANCEL_ORDER.rawValue {
            let controller =  ShippingServiceRouter.instantiateShippingServicesViewController()
            controller.scheduledItemType = .shipment
            controller.isMine = true
            UIApplication.topViewController()?.navigationController?.pushViewController(controller, animated: true)
        } else if name == NotificationName.UPDATE_ORDER_STATE.rawValue {
            let controller = FeedingRouter.instantiateFeedingOrdersNavigationViewController()
            UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
        }
    }
}
