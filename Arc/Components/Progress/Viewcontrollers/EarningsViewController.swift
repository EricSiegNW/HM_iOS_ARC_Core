//
//  EarningsViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/14/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class EarningsViewController: CustomViewController<ACEarningsView> {
	var thisStudy:ThisStudyExpressible = Arc.shared.studyController
	var thisWeek:ThisWeekExpressible = Arc.shared.studyController

	var lastUpdated:TimeInterval?
	var earningsData:EarningOverview?
	var dateFormatter = DateFormatter()
	var isPostTest:Bool = false
	var timeout:Timer?
    // TODO
    // This enum was copypasta'd from ACEarningsDetailView
    // Don't do that
    enum GoalDisplayName : String {
        case testSession = "test-session"
        case fourOfFour = "4-out-of-4"
        case twoADay = "2-a-day"
        case totalSessions =  "21-sessions"
        
        func getName() ->String {
            switch self {
                
                
            case .testSession:
                return "Completed Test Session"
            case .fourOfFour:
                return "4 Out of 4 Goal"
            case .twoADay:
                return "2-A-Day Goal"
            case .totalSessions:
                return "21 Sessions Goal"
                
            }
        }
    }
	
	public init(isPostTest:Bool) {
		super.init(nibName: nil, bundle: nil)
		self.isPostTest = isPostTest
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override public func viewDidLoad() {
		
        super.viewDidLoad()
		customView.scrollIndicatorView.isHidden = true
		
		//When in post test mode perform modifications
		lastUpdated = app.appController.lastFetched["EarningsOverview"]

		if isPostTest {
			timeout = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] (timer) in
				
				if let lastKnownUpdate = self?.lastUpdated,
					let updated = Arc.shared.appController.lastFetched["EarningsOverview"],
						 lastKnownUpdate == updated,
						fabs(updated - Date().timeIntervalSince1970) > 10 * 60{
					self?.errorState()

				
				}
				
			}
			customView.nextButton?.addTarget(self, action: #selector(self.nextPressed), for: .touchUpInside)
			
            configureForPostTest()
			
		} else {
			configureForTab()
		}
        
		dateFormatter.locale = app.appController.locale.getLocale()
		dateFormatter.dateFormat = "MMM dd 'at' hh:mm a"
		NotificationCenter.default.addObserver(self, selector: #selector(updateEarnings(notification:)), name: .ACEarningsUpdated, object: nil)
		
		customView.viewDetailsButton.addAction {
			[weak self] in
            guard self != nil else {
				return
			}
			self?.navigationController?.pushViewController(EarningsDetailViewController(), animated: true)
		}
        // Do any additional setup after loading the view.
		
		
    }
	fileprivate func errorState() {
		customView.earningsSection.isHidden = true
		customView.bonusGoalsHeader.isHidden = true
		customView.bonusGoalContent.isHidden = true
		customView.bonusGoalsSection.isHidden = true
		customView.errorLabel.isHidden = false
		customView.hideSpinner()
		customView.earningsParentStack.fadeIn()
	}
	fileprivate func configureForTab() {
//		customView.root.refreshControl = UIRefreshControl()
//		customView.root.addSubview(customView.root.refreshControl!)
//		customView.root.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
//
//		customView.root.alwaysBounceVertical = true
		
		customView.button.addTarget(self, action: #selector(self.viewFaqPressed), for: .touchUpInside)
	}
	fileprivate func configureForPostTest() {
		
		customView.earningsSection.isHidden = false
		customView.bonusGoalsHeader.isHidden = false
		customView.bonusGoalContent.isHidden = false
		customView.bonusGoalsSection.isHidden = false
		customView.errorLabel.isHidden = true
		customView.backgroundView.image = UIImage(named: "finished_bg", in: Bundle(for: self.classForCoder), compatibleWith: nil)
		customView.backgroundColor = UIColor(named: "Primary Info")
		customView.button.isHidden = true
		customView.gradientView?.isHidden = false
		customView.earningsSection.backgroundColor = .clear
		customView.headerLabel.textAlignment = .center
		customView.headerLabel.text = "".localized(ACTranslationKey.progress_earnings_header)
		
		customView.viewDetailsButton.isHidden = true
		customView.separator.isHidden = true
		customView.earningsBodyLabel.isHidden = true
		customView.lastSyncedLabel.isHidden = true
		
		customView.bonusGoalsSection.backgroundColor = .clear
		customView.bonusGoalsHeader.textAlignment = .center
		customView.bonusGoalsSeparator.isHidden = true
		customView.bonusGoalsHeader.textColor = .white
		customView.bonusGoalsBodyLabel.textColor = .white
		
		customView.bonusGoalsBodyLabel.textAlignment = .center
		Roboto.Style.body(customView.bonusGoalsBodyLabel, color:.white)
		
		customView.earningsParentStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 88, right: 0)
		
		
	}
    @objc func nextPressed() {
		if thisStudy.studyState == .inactive {
			Arc.shared.appNavigation.navigate(vc: ACPostCycleFinishViewController(), direction: .toRight)
		} else {
			Arc.shared.nextAvailableState()

		}
    }
    
    @objc func viewFaqPressed() {
        let vc:FAQViewController = .get()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
	@objc func refresh(sender:AnyObject)
	{
		
		//my refresh code here..
		print("refreshing")
		NotificationCenter.default.post(name: .ACStartEarningsRefresh, object: nil)
	}
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
		if isPostTest && fabs((lastUpdated ?? Date().timeIntervalSince1970) - Date().timeIntervalSince1970) > 10 * 60 {
			customView.showSpinner(color: ACColor.highlight, backgroundColor: ACColor.primaryInfo, message:"progress_endoftest_syncing")
			customView.earningsParentStack.alpha = 0
			

		}
		
	}
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		if isPostTest && !HMRestAPI.shared.isWaitingForTask(named: ["earning-details", "earning-overview"]){
//			customView.hideSpinner()
//			customView.earningsParentStack.fadeIn()
//
//		}
		lastUpdated = app.appController.lastFetched["EarningsOverview"]
		earningsData = Arc.shared.appController.read(key: "EarningsOverview")
		setGoals()
	}
	@objc public func updateEarnings(notification:Notification) {
		OperationQueue.main.addOperation { [weak self] in

			guard let weakSelf = self else {
				return
			}
			weakSelf.timeout?.invalidate()
			weakSelf.customView.earningsParentStack.fadeIn()

			
			

			weakSelf.lastUpdated = weakSelf.app.appController.lastFetched["EarningsOverview"]
			weakSelf.earningsData = Arc.shared.appController.read(key: "EarningsOverview")
			weakSelf.setGoals()
			weakSelf.customView.hideSpinner()
			weakSelf.customView.root.refreshControl?.endRefreshing()
			
		}
		
	}
	
	fileprivate func updateBodyText() {
		if let last = lastUpdated {
			let date = Date(timeIntervalSince1970: last)
			if date.addingMinutes(minutes: 1).minutes(from: Date()) < 1 {
				customView.lastSyncedLabel.text = "\("".localized(ACTranslationKey.earnings_sync)) \(dateFormatter.string(from: date))"
			}
		}
		customView.bonusGoalsBodyLabel.text = "".localized(ACTranslationKey.earnings_bonus_body)
		
		switch thisStudy.studyState {
		case .baseline:
			customView.earningsBodyLabel.text = "".localized(ACTranslationKey.earnings_body0)
			
			break
		default:
			customView.earningsBodyLabel.text = "".localized(ACTranslationKey.earnings_body1)
			
			
			break
		}
	}
	
	fileprivate func fourofFourGoal(_ fourOfFourGoal:EarningOverview.Response.Earnings.Goal) {
		let components = fourOfFourGoal.progress_components
		
		for component in components.enumerated() {
			let index = component.offset
			let value = component.element
			customView.fourofFourGoal.set(progress:Double(value)/100.0, for: index)
		}
		
		customView.fourofFourGoal.set(isUnlocked: fourOfFourGoal.completed)
		customView.fourofFourGoal.set(bodyText: "".localized(ACTranslationKey.earnings_4of4_body)
			.replacingOccurrences(of: "{AMOUNT}", with: fourOfFourGoal.value))
		customView.fourofFourGoal.goalRewardView.set(text: fourOfFourGoal.value)
	}
	
	fileprivate func twoADayGoal(_ twoADay:EarningOverview.Response.Earnings.Goal) {
		let components = twoADay.progress_components.suffix(7)
		for component in components.enumerated() {
			let index = component.offset
			let value = component.element
			customView.twoADayGoal.set(progress:Double(min(2, value))/2.0, forIndex: index)
		}
		customView.twoADayGoal.set(isUnlocked: twoADay.completed)
		customView.twoADayGoal.set(bodyText: "".localized(ACTranslationKey.earnings_2aday_body)
			.replacingOccurrences(of: "{AMOUNT}", with: twoADay.value))
		customView.twoADayGoal.goalRewardView.set(text: twoADay.value)
	}
	
	fileprivate func totalSessionsGoal(_ totalSessions:EarningOverview.Response.Earnings.Goal) {
		for component in totalSessions.progress_components.enumerated() {
			let value = component.element
			customView.totalSessionsGoal.set(total: 21.0)
			customView.totalSessionsGoal.set(current: value)
			
		}
		
		customView.totalSessionsGoal.set(isUnlocked: totalSessions.completed)
		customView.totalSessionsGoal.set(bodyText: "".localized(ACTranslationKey.earnings_21tests_body)
			.replacingOccurrences(of: "{AMOUNT}", with: totalSessions.value))
		customView.totalSessionsGoal.goalRewardView.set(text: totalSessions.value)
	}
	
	public func setGoals() {
		
		
		updateBodyText()
		
		customView.twoADayGoal.add(tiles: thisWeek.daysArray.suffix(7))
		guard let earnings = earningsData?.response?.earnings else {
			return
		}
		if isPostTest {
			customView.clearRewards()
			for a in earnings.new_achievements {
                let name = GoalDisplayName(rawValue: a.name)?.getName() ?? "Goal Name"
				customView.add(reward: (name, a.amount_earned))
			}
		}
		
		customView.thisWeeksEarningsLabel.text = earnings.total_earnings
		customView.thisStudysEarningsLabel.text = earnings.cycle_earnings
		
		for goal in earnings.goals {
			switch goal.name {
			case "4-out-of-4":
				fourofFourGoal(goal)
			case "2-a-day":
				twoADayGoal(goal)
			case "21-sessions":
				totalSessionsGoal(goal)
			default:
				break
			}
		}
	}
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

