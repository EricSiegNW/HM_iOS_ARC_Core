//
//  IntroViewController.swift
// Arc
//
//  Created by Philip Hayes on 9/28/18.
//  Copyright © 2018 healthyMedium. All rights reserved.
//

import UIKit
import HMMarkup
import ArcUIKit
public enum IntroViewControllerStyle : String {
	case standard, dark, test, gridTest, symbolTest, priceTest
	
	public func set(view:InfoView, heading:String?, subheading:String?, content:String?, template:[String:String] = [:]) {
		switch self {
		case .standard:
			view.setHeading(heading)
			view.setSubHeading(subheading)
			view.setContentText(content, template: template)
		case .test, .gridTest, .symbolTest, .priceTest:
			view.setSubHeading(heading)
			view.setHeading(subheading)
			view.setSeparatorWidth(0.0)
			view.setContentText(content, template: template)
			view.backgroundColor = UIColor(named:"Primary Info")
			view.infoContent.alignment = .leading
			
			
		
		case .dark:
			view.setSubHeading(heading)
			view.setHeading(subheading)
			view.setSeparatorWidth(0.0)
			view.setContentText(content, template: template)
			view.backgroundColor = UIColor(named:"Primary Info")
			view.infoContent.alignment = .leading
		}
	}
}
open class IntroViewController: CustomViewController<InfoView> {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subheadingLabel: UILabel!
    @IBOutlet weak var contentTextview: UITextView!
	@IBOutlet weak var nextButton:UIButton!
    var nextButtonImage:String?
	var style:IntroViewControllerStyle = .standard
    var heading:String?
    var subheading:String?
    var content:String?
	var nextButtonTitle:String?
    var nextPressed:(()->Void)?
    var templateHandler:((Int)->Dictionary<String,String>)?
    var instructionIndex:Int = 0
	var shouldHideBackButton = false
    var isIntersitial = false

	
    override open func viewDidLoad() {
        super.viewDidLoad()
		customView.backgroundColor = UIColor(named: "Primary")
        // Do any additional setup after loading the view.
		if let nav = self.navigationController, nav.viewControllers.count > 1 {
			let backButton = UIButton(type: .custom)
			backButton.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
			backButton.setImage(UIImage(named: "cut-ups/icons/arrow_left_white"), for: .normal)
			backButton.setTitle("BACK".localized("button_back"), for: .normal)
			backButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 14)
			backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
			//backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
			backButton.setTitleColor(UIColor(named: "Secondary"), for: .normal)
			backButton.backgroundColor = UIColor(named:"Secondary Back Button Background")
			backButton.layer.cornerRadius = 16.0
			backButton.addTarget(self, action: #selector(self.backPressed), for: .touchUpInside)
			//NSLayoutConstraint(item: backButton, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: super.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: -75).isActive = true
			let leftButton = UIBarButtonItem(customView: backButton)
			
			//self.navigationItem.setLeftBarButton(leftButton, animated: true)
			self.navigationItem.leftBarButtonItem = leftButton
		}

    }
	@objc func backPressed() {
		self.navigationController?.popViewController(animated: true)
	}
    @IBAction func nextButtonPressed(_ sender: Any) {
        nextPressed?()
    }
	public func set(heading:String?, subheading:String?, content:String?, template:[String:String] = [:]) {
		
        
		style.set(view: customView, heading: heading, subheading: subheading, content: content, template: template)
		if style == .test {
			let button = HMMarkupButton()
			button.setTitle("View a Tutorial", for: .normal)
			Roboto.Style.bodyBold(button.titleLabel!, color:.white)
			Roboto.PostProcess.link(button)
			button.addAction {[weak self] in
				self?.present(PricesTestTutorialViewController(), animated: true) {
					
				}
			}
			customView.setMiscContent(button)
		}
    }
	public func updateNextbutton() {
		if let nextButtonTitle = nextButtonTitle, !nextButtonTitle.isEmpty {
			customView.nextButton?.setTitle(nextButtonTitle.localized(nextButtonTitle), for: .normal)
		} else {
			if nextButtonImage == nil {
				customView.nextButton?.setTitle("NEXT".localized("button_next"), for: .normal)
			} else {
				customView.nextButton?.setTitle(nil, for: .normal)
			}
		}
		
		if let nextButtonTitle = nextButtonImage {
			customView.nextButton?.setImage(UIImage(named: nextButtonTitle), for: .normal)
		} else {
			customView.nextButton?.setImage(nil, for: .normal)
			
		}
		customView.nextPressed = nextPressed
	}
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldHideBackButton {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.leftBarButtonItem?.customView?.isHidden = true
        }

		self.navigationItem.rightBarButtonItem = nil
        
		
		
        self.navigationController?.navigationBar.backgroundColor = .clear
		updateNextbutton()
    }
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if style != .standard {
			customView.setSeparatorWidth(0.15)
		}

	}
	
	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		//contentTextview.setContentOffset(CGPoint.zero, animated: false)

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
