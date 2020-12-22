//
//  CrashBrowser.swift
//  SwiftAPM
//
//  Created by rongheng on 2020/10/12.
//

import UIKit

extension Notification.Name {
    public static let OpenCrashBrowser = Notification.Name("OpenCrashBrowser")
}

public final class CrashBrowser {
    
    public static let share : CrashBrowser = CrashBrowser()
    
    private init() { }
    
    /// 打开 Crash List
    public func openCrashList() {
        mainThread {
            self.handleOepn()
        }
    }
    
    func handleOepn() {
        let oldKeyWindow = UIApplication.shared.keyWindow
        
        let window = UIWindow(frame:UIScreen.main.bounds)
        window.backgroundColor = .white
        
        let allCrash : [Crash.Data] = Storage.shared.values(for: .Crash)
        let listController = CrashBrowserListController(dataSource: allCrash)
        listController.closeTapAction = {
            window.isHidden = true
            window.removeFromSuperview()
        }

        // show
        window.rootViewController = UINavigationController(rootViewController: listController)
        window.isHidden = false
        
        oldKeyWindow?.addSubview(window)
    }
}


public class CrashBrowserListController: UIViewController {
    let dataSource : [Crash.Data]
    
    var closeTapAction: (() -> ())?
    
    lazy var previewVC = PreviewLogController()
    
    init(dataSource: [Crash.Data]) {
        self.dataSource = dataSource
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var listView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 50)
        layout.minimumLineSpacing = 5;
        let listView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        listView.backgroundColor = .black
        listView.register(BrowserListCell.self, forCellWithReuseIdentifier: BrowserListCell.identifier)
        listView.dataSource = self
        listView.delegate = self
        return listView
    }()
    
    lazy var closeButton : UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("关闭", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(listView)
        view.addSubview(closeButton)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenBounds = UIScreen.main.bounds
        self.listView.frame = .init(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height - 40)
        self.closeButton.frame = .init(x: 0, y: screenBounds.height - 40, width: screenBounds.width, height: 40)
    }
    
    @objc func closeTap() {
        closeTapAction?()
    }
}

extension CrashBrowserListController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowserListCell.identifier, for: indexPath) as! BrowserListCell
        let crash = dataSource[indexPath.item]
        cell.titleLabel.text = "\(crash.date)-\(crash.name)"
        return cell
    }
}

extension CrashBrowserListController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let crash = dataSource[indexPath.item]
        previewVC.openContent(crash.callStack)
        
        navigationController?.pushViewController(previewVC, animated: true)
    }
}

class BrowserListCell: UICollectionViewCell {
    
    static let identifier = "BrowserListCell"
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.contentView.addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = bounds
    }
}

final class PreviewLogController: UIViewController {
    lazy var contentView : UITextView = {
        let view = UITextView()
        view.backgroundColor = .white
        view.textColor = .black
        view.font = .italicSystemFont(ofSize: 12)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        contentView.contentOffset = .zero
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentView.frame = view.bounds
    }
    
    func openContent(_ content: String) {
        contentView.text = content
    }
}
