//
//  TestCountDownViewController.swift
//  Arc
//
//  Created by Philip Hayes on 8/5/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class TestCountDownViewController: CustomViewController<TestCountDownView> {
	public var nextVc:UIViewController?
	
	init(nextVc:UIViewController) {
		self.nextVc = nextVc
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	override public func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        self.customView.countLabel.font = UIFont(name: "Georgia-Italic", size: 96)
		Animate().duration(0).delay(1.0).run { [weak self]
			t in
			self?.customView.countLabel.text = "2"
			return true
		}
		Animate().duration(0).delay(2.0).run { [weak self]
			t in
			self?.customView.countLabel.text = "1"
			return true
		}
		Animate().duration(0).delay(3.0).run { [weak self]
			t in
			
			guard let weakSelf = self else {
				return false
			}
			weakSelf.app.appNavigation.navigate(vc: weakSelf.nextVc!, direction: .toTop)
			weakSelf.nextVc = nil
			return true
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
