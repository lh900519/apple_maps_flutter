//
//  FlutterAnnotation2View.swift
//  Pods
//
//  Created by liuhaibo on 2025/7/6.
//

import Foundation
import MapKit
import UIKit

class FlutterAnnotation2View: MKAnnotationView {
  private let displayContainerView = UIView()
  private let bubbleView = UIView()
  private let blurView = UIVisualEffectView(
    effect: UIBlurEffect(style: .systemMaterialLight)
  )
  private let titleLabel = UILabel()
  private let pointView = UIView()
  private let countLabel = UILabel()

  private let maxAnnotationWidth: CGFloat = 260
  private let maxAnnotationHeight: CGFloat = 180
  private let maxBubbleWidth: CGFloat = 220
  private let maxBubbleHeight: CGFloat = 60
  private let minBubbleHeight: CGFloat = 36
  private let bubbleHorizontalPadding: CGFloat = 8
  private let bubbleVerticalPadding: CGFloat = 4
  private let bubblePointGap: CGFloat = 8
  private let plainPointDiameter: CGFloat = 11
  private let plainPointBorderWidth: CGFloat = 2
  private let countPointHeight: CGFloat = 20
  private let countPointMinimumWidth: CGFloat = 20
  private let countPointHorizontalPadding: CGFloat = 12
  private let countPointBorderWidth: CGFloat = 1
  private let titleFontSize: CGFloat = 13
  private let countFontSize: CGFloat = 13

  private var bubbleWidthConstraint: NSLayoutConstraint!
  private var bubbleHeightConstraint: NSLayoutConstraint!
  private var pointWidthConstraint: NSLayoutConstraint!
  private var pointHeightConstraint: NSLayoutConstraint!

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  private func setupView() {
    canShowCallout = true
    frame = CGRect(
      x: 0,
      y: 0,
      width: maxAnnotationWidth,
      height: maxAnnotationHeight
    )

    bubbleView.layer.cornerRadius = 12
    bubbleView.layer.shadowColor = UIColor.black.cgColor
    bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
    bubbleView.layer.shadowOpacity = 0.12
    bubbleView.layer.shadowRadius = 5

    blurView.layer.cornerRadius = 12
    blurView.clipsToBounds = true
    blurView.contentView.backgroundColor = UIColor(
      white: 1,
      alpha: 179.0 / 255.0
    )

    titleLabel.font = UIFont.systemFont(
      ofSize: titleFontSize,
      weight: .regular
    )
    titleLabel.textColor = UIColor(
      red: 17.0 / 255.0,
      green: 17.0 / 255.0,
      blue: 17.0 / 255.0,
      alpha: 1.0
    )
    titleLabel.textAlignment = .left
    titleLabel.numberOfLines = 2
    titleLabel.lineBreakMode = .byTruncatingTail

    pointView.backgroundColor = UIColor(
      red: 1.0,
      green: 0.68,
      blue: 0.08,
      alpha: 1.0
    )
    pointView.layer.borderColor = UIColor.white.cgColor
    pointView.layer.borderWidth = plainPointBorderWidth

    countLabel.font = UIFont.systemFont(
      ofSize: countFontSize,
      weight: .semibold
    )
    countLabel.textColor = .white
    countLabel.textAlignment = .center
    countLabel.adjustsFontSizeToFitWidth = true
    countLabel.minimumScaleFactor = 0.7
    countLabel.isHidden = true

    addSubview(displayContainerView)
    displayContainerView.addSubview(bubbleView)
    bubbleView.addSubview(blurView)
    bubbleView.addSubview(titleLabel)
    displayContainerView.addSubview(pointView)
    pointView.addSubview(countLabel)

    displayContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    setupConstraints()
  }

  private func setupConstraints() {
    displayContainerView.translatesAutoresizingMaskIntoConstraints = false
    bubbleView.translatesAutoresizingMaskIntoConstraints = false
    blurView.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    pointView.translatesAutoresizingMaskIntoConstraints = false
    countLabel.translatesAutoresizingMaskIntoConstraints = false

    bubbleWidthConstraint = bubbleView.widthAnchor.constraint(
      equalToConstant: maxBubbleWidth
    )
    bubbleHeightConstraint = bubbleView.heightAnchor.constraint(
      equalToConstant: maxBubbleHeight
    )
    pointWidthConstraint = pointView.widthAnchor.constraint(
      equalToConstant: plainPointDiameter
    )
    pointHeightConstraint = pointView.heightAnchor.constraint(
      equalToConstant: plainPointDiameter
    )

    NSLayoutConstraint.activate([
      displayContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      displayContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      displayContainerView.topAnchor.constraint(equalTo: topAnchor),
      displayContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

      pointView.centerXAnchor.constraint(
        equalTo: displayContainerView.centerXAnchor
      ),
      pointView.centerYAnchor.constraint(
        equalTo: displayContainerView.centerYAnchor
      ),
      pointWidthConstraint,
      pointHeightConstraint,

      bubbleView.centerXAnchor.constraint(equalTo: pointView.centerXAnchor),
      bubbleView.bottomAnchor.constraint(
        equalTo: pointView.topAnchor,
        constant: -bubblePointGap
      ),
      bubbleWidthConstraint,
      bubbleHeightConstraint,

      blurView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
      blurView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
      blurView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
      blurView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),

      titleLabel.leadingAnchor.constraint(
        equalTo: bubbleView.leadingAnchor,
        constant: bubbleHorizontalPadding
      ),
      titleLabel.trailingAnchor.constraint(
        equalTo: bubbleView.trailingAnchor,
        constant: -bubbleHorizontalPadding
      ),
      titleLabel.topAnchor.constraint(
        equalTo: bubbleView.topAnchor,
        constant: bubbleVerticalPadding
      ),
      titleLabel.bottomAnchor.constraint(
        equalTo: bubbleView.bottomAnchor,
        constant: -bubbleVerticalPadding
      ),

      countLabel.leadingAnchor.constraint(
        equalTo: pointView.leadingAnchor,
        constant: countPointHorizontalPadding
      ),
      countLabel.trailingAnchor.constraint(
        equalTo: pointView.trailingAnchor,
        constant: -countPointHorizontalPadding
      ),
      countLabel.topAnchor.constraint(equalTo: pointView.topAnchor),
      countLabel.bottomAnchor.constraint(equalTo: pointView.bottomAnchor),
    ])
  }

  private func updateBubbleSize(for text: String?) {
    guard let text = text, !text.isEmpty else {
      bubbleView.isHidden = true
      bubbleWidthConstraint.constant = 0
      bubbleHeightConstraint.constant = 0
      return
    }

    bubbleView.isHidden = false
    let maxTextWidth = maxBubbleWidth - 2 * bubbleHorizontalPadding
    let maxTextHeight = maxBubbleHeight - 2 * bubbleVerticalPadding
    let textAttributes: [NSAttributedString.Key: Any] = [
      .font: titleLabel.font as Any,
    ]
    let textSize = (text as NSString).boundingRect(
      with: CGSize(width: maxTextWidth, height: maxTextHeight),
      options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
      attributes: textAttributes,
      context: nil
    ).size

    bubbleWidthConstraint.constant = min(
      maxBubbleWidth,
      max(0, ceil(textSize.width) + 2 * bubbleHorizontalPadding)
    )
    bubbleHeightConstraint.constant = min(
      maxBubbleHeight,
      max(minBubbleHeight, ceil(textSize.height) + 2 * bubbleVerticalPadding)
    )
  }

  private func updatePoint(for count: Int?) {
    let displayCount: String?
    if let count = count, count >= 2 {
      displayCount = String(count)
    } else {
      displayCount = nil
    }

    countLabel.text = displayCount
    countLabel.isHidden = displayCount == nil

    let pointWidth: CGFloat
    let pointHeight: CGFloat
    if let displayCount = displayCount {
      let textAttributes: [NSAttributedString.Key: Any] = [
        .font: countLabel.font as Any,
      ]
      let textSize = (displayCount as NSString).size(withAttributes: textAttributes)
      pointWidth = max(
        countPointMinimumWidth,
        ceil(textSize.width) + 2 * countPointHorizontalPadding
      )
      pointHeight = countPointHeight
      pointView.layer.borderWidth = countPointBorderWidth
    } else {
      pointWidth = plainPointDiameter
      pointHeight = plainPointDiameter
      pointView.layer.borderWidth = plainPointBorderWidth
    }

    pointWidthConstraint.constant = pointWidth
    pointHeightConstraint.constant = pointHeight
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    pointView.layer.cornerRadius = pointView.bounds.height / 2
    bubbleView.layer.shadowPath = UIBezierPath(
      roundedRect: bubbleView.bounds,
      cornerRadius: bubbleView.layer.cornerRadius
    ).cgPath
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    titleLabel.text = nil
    countLabel.text = nil
    countLabel.isHidden = true
    bubbleView.isHidden = false
    bubbleWidthConstraint.constant = maxBubbleWidth
    bubbleHeightConstraint.constant = maxBubbleHeight
    pointWidthConstraint.constant = plainPointDiameter
    pointHeightConstraint.constant = plainPointDiameter
    pointView.layer.borderWidth = plainPointBorderWidth
    displayContainerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
  }

  func configure(with annotation: FlutterAnnotation) {
    self.annotation = annotation
    titleLabel.text = annotation.title
    updateBubbleSize(for: annotation.title)
    updatePoint(for: annotation.count)
    setNeedsLayout()
    layoutIfNeeded()

    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 0.5,
      options: .curveEaseInOut,
      animations: {
        self.displayContainerView.transform = .identity
      },
      completion: nil
    )
  }

  func updateSelected(with isSelected: Bool) {
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 0.5,
      options: .curveEaseInOut
    ) {
      self.displayContainerView.transform = isSelected
        ? CGAffineTransform(scaleX: 1.3, y: 1.3)
        : .identity
    }
  }
}
