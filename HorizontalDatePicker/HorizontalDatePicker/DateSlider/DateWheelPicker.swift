//
//  DateWheelPicker.swift
//  DateWheelPicker
//
//  Created by Trần Mạnh Quý on 9/16/20.
//  Copyright © 2020 Trần Mạnh Quý. All rights reserved.
//

import UIKit

protocol DateItemInterface {
    var index: Int {get set}
    func isCenter(_ center: Bool)
}

class DateWheelPicker: UICollectionView {
    
    @IBInspectable var range: Int = 5
    @IBInspectable var canLoadFuture: Bool = false
    
    fileprivate var itemPerLine: Int = 5
    fileprivate var listRawDate = [Date]()
    fileprivate var selectedDate = Date()
    fileprivate var currentDate = Date()
    fileprivate var isFirstLoad = true
    fileprivate let dayInSec = TimeInterval(86400)
    fileprivate var lastOffset = CGPoint.zero
    fileprivate var isScrollLeft = true
    fileprivate var onSelectedDate: ((Date) -> Void)?
    
    lazy var cellWidth: CGFloat = {
        return self.bounds.width / CGFloat(itemPerLine)
    }()
    lazy var horInset = 2 * cellWidth
    
    let setComponent = Set<Calendar.Component>(
        arrayLiteral: Calendar.Component.weekday,
        Calendar.Component.day,
        Calendar.Component.month,
        Calendar.Component.year)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.dataSource = self
        self.delegate = self
        
        (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        self.isPagingEnabled = false
        register(UINib(nibName: DateCollectionCell.typeName, bundle: Bundle.main), forCellWithReuseIdentifier: DateCollectionCell.typeName)
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initDateItem()
    }
    
    // MARK: - Ultility methods
    private func getDateComponents(_ date: Date) -> (Int, Int, Int, Int)? {
        let component = Calendar.current.dateComponents(setComponent, from: date)
        guard let d = component.day, let m = component.month, let w = component.weekday, let y = component.year else { return nil }
        return (d, m, w, y)
    }
    
    func onSelectedDate(_ completion: @escaping (Date) -> Void) {
        self.onSelectedDate = completion
    }
    
    func getCurrentDate() -> Date {
        return self.currentDate
    }
    
    func getSelectedDate() -> Date {
        return self.selectedDate
    }
    
    // MARK: - Inititalize list of Date
    func initDateItem() {
        guard let lowerBound = Calendar.current.date(byAdding: Calendar.Component.day, value: -range, to: currentDate) else { return }
        listRawDate.append(lowerBound)
        let upperBound = canLoadFuture ? range*2 : (range + itemPerLine / 2)
        for index in 1...upperBound {
            let date  = lowerBound.addingTimeInterval(Double(index) * dayInSec)
            listRawDate.append(date)
        }
        reloadData()
        performBatchUpdates(nil, completion:{ [unowned self] a in
            self.scrollRectToVisible(CGRect(x: CGFloat(self.listRawDate.count / 2 - 2) * self.cellWidth + self.horInset, y: 0, width: self.bounds.width, height: self.bounds.height), animated: true)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension DateWheelPicker: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listRawDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionCell.typeName, for: indexPath) as! DateCollectionCell
        guard let compo = getDateComponents(listRawDate[indexPath.row]) else { return cell }
        cell.labelDate.text = "\(compo.0)"
        cell.labelMonth.text = "thg \(compo.1)"
        let weekday = compo.2
        cell.labelWeekDay.text = weekday == 1 ? "CN" : "th \(weekday)"
        cell.index = indexPath.item
        return cell
    }
}

extension DateWheelPicker: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: self.bounds.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: horInset, bottom: 0, right: horInset)
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isScrollLeft = lastOffset.x < scrollView.contentOffset.x
        triggerSelectedAnimation()
        freezeScroll(scrollView)
        lastOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        triggerStepWheel(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            triggerStepWheel(scrollView)
        }
    }
    
    /**
     This func will freeze scroll when we reach bound, to ensure that user can not select bound-value
     */
    func freezeScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >=
            scrollView.contentSize.width - scrollView.bounds.width { // Right-side
            scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - scrollView.bounds.width, y: 0), animated: false)
        } else if scrollView.contentOffset.x <= 0 { // Left-side
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    /**
     This function will trigger selected item by indicator
     */
    func triggerSelectedAnimation() {
        let currentCenterPoint = CGPoint(x: self.contentOffset.x + self.bounds.width / 2, y: self.bounds.height / 2)
        for cell in visibleCells {
            if cell is DateItemInterface {
                if currentCenterPoint.x <= cell.frame.maxX && currentCenterPoint.x >= cell.frame.minX {
                    (cell as! DateItemInterface).isCenter(true)
                    selectedDate = listRawDate[(cell as! DateItemInterface).index]
                } else {
                    (cell as! DateItemInterface).isCenter(false)
                }
            }
        }
    }
    
    /**
     This function will trigger Step-roll animation like real wheel
     */
    private func triggerStepWheel(_ scrollView: UIScrollView) {
        var currentOffset = scrollView.contentOffset
        let remainder = currentOffset.x.truncatingRemainder(dividingBy: cellWidth)
        if remainder != 0 || (currentOffset.x == 0 && remainder == 0) {
            if isScrollLeft  {
                currentOffset.x = currentOffset.x + (remainder >= 0.5 * cellWidth ? cellWidth - remainder : -remainder)
            } else {
                currentOffset.x = currentOffset.x - (remainder >= 0.5 * cellWidth ? -(cellWidth - remainder) : remainder)
            }
            UIView.animate(withDuration: TimeInterval(0.2)) { [weak self] in
                scrollView.contentOffset = currentOffset
                if let date = self?.selectedDate {
                    self?.onSelectedDate?(date)
                }
            }
        }
    }
}


