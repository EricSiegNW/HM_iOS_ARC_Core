//
//  GoalDayTile.swift
//  Arc
//
//  Created by Philip Hayes on 8/16/19.
//  Copyright © 2019 HealthyMedium. All rights reserved.
//

import UIKit
import ArcUIKit
public class GoalDayTile: UIView {
	weak var progressView:CircularProgressView!
	weak var titleLabel:ACLabel!
	override init(frame: CGRect) {
		super.init(frame: .zero)
		build()
	}
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		build()
	}
	
	func build() {
		translatesAutoresizingMaskIntoConstraints = false
		stack {[unowned self] in 
			$0.axis = .vertical
			$0.spacing = 8
			$0.alignment = .center
			$0.attachTo(view: $0.superview, margins: UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0))
			self.progressView = $0.circularProgress {
				$0.layout {
					$0.width == 24 ~ 999
					$0.height == 24 ~ 999

				}
				$0.config.strokeWidth = 2
				$0.config.trackColor = ACColor.highlight
				$0.config.barColor = ACColor.primary
			}
			self.titleLabel = $0.acLabel {
				Roboto.Style.body($0, color: ACColor.badgeText)
			}
		}
	}
	public func set(title:String) {
		titleLabel.text = title
	}
	
	public func set(progress:Double) {
		progressView.progress = progress
	}
}
extension UIView {
	@discardableResult
	public func goalDayTile(apply closure: (GoalDayTile) -> Void) -> GoalDayTile {
		custom(GoalDayTile(), apply: closure)
	}
}

