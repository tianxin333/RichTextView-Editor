//
//  ViewController.swift
//  RichTextView-Editor
//
//  Created by tx on 2020/4/17.
//  Copyright © 2020 tx. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var styleTb: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isBoldEnabled = false
    var isItalicEnabled = false
    var isUnderlineEnabled = false
    var isDeletelineEnabled = false
 
    var updatingTextRange: NSRange = NSMakeRange(0, 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextView.delegate = self
        
        //        initTextView()
        
        
        configureTextView()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view's height accordingly.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(ViewController.handleKeyboardNotification(_:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(ViewController.handleKeyboardNotification(_:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK: - Keyboard Event Notifications
    
    @objc
    func handleKeyboardNotification(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        // Get the animation duration.
        var animationDuration: TimeInterval = 0
        if let value = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = value.doubleValue
        }
        
        // Convert the keyboard frame from screen to view coordinates.
        var keyboardScreenBeginFrame = CGRect()
        if let value = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue) {
            keyboardScreenBeginFrame = value.cgRectValue
        }
        
        var keyboardScreenEndFrame = CGRect()
        if let value = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
            keyboardScreenEndFrame = value.cgRectValue
        }
        
        let keyboardViewBeginFrame = view.convert(keyboardScreenBeginFrame, from: view.window)
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        // The text view should be adjusted, update the constant for this constraint.
        //        textViewBottomLayoutGuideConstraint.constant -= originDelta
        
        if originDelta < 0 {//弹出软键盘
            keyBoardWillShow(notification as NSNotification)
        }else{
            keyBoardWillHide(notification as NSNotification)
        }
        
        // Inform the view that its autolayout constraints have changed and the layout should be updated.
        view.setNeedsUpdateConstraints()
        
        // Animate updating the view's layout by calling layoutIfNeeded inside a `UIViewPropertyAnimator` animation block.
        let textViewAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        textViewAnimator.startAnimation()
        
        // Scroll to the selected text once the keyboard frame changes.
        let selectedRange = contentTextView.selectedRange
        contentTextView.scrollRangeToVisible(selectedRange)
    }
    
    
    
    func initTextView(){
        //是否允许点击链接和附件
        contentTextView.isSelectable = true
        
        //返回键的类型
        contentTextView.returnKeyType = UIReturnKeyType.done
        
        //键盘类型
        contentTextView.keyboardType = UIKeyboardType.default
        
        //处于焦点状态
        contentTextView.becomeFirstResponder()
        
    }
    
    
    func configureTextView() {
        
        contentTextView.isScrollEnabled = true
        
        // Apply different attributes to the text (bold, tinted, underline, etc.).
        reflowTextAttributes()
        
        /** When turned on, this changes the rendering scale of the text to match the standard text scaling
         and preserves the original font point sizes when the contents of the text view are copied to the pasteboard.
         Apps that show a lot of text content, such as a text viewer or editor, should turn this on and use the standard text scaling.
         */
        contentTextView.usesStandardTextScaling = true
    }
    
    
    // MARK: - Configuration
    
    func reflowTextAttributes() {
        var entireTextColor = UIColor.black
        
        // The text should be white in dark mode.
        if self.view.traitCollection.userInterfaceStyle == .dark {
            entireTextColor = UIColor.white
        }
        let entireAttributedText = NSMutableAttributedString(attributedString: contentTextView.attributedText!)
        let entireRange = NSRange(location: 0, length: entireAttributedText.length)
        entireAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: entireTextColor, range: entireRange)
        contentTextView.attributedText = entireAttributedText
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // With the background change, we need to re-apply the text attributes.
        reflowTextAttributes()
    }
    
    
    @IBAction func addTag(_ sender: Any) {
        
    }
    
    
    //显示字体设置
    @IBAction func addStyle(_ sender: Any) {
        toolbar.isHidden = true
        styleTb.isHidden = false
        scrollView.isHidden = false
        
    }
    
    //隐藏字体设置
    @IBAction func hideStyle(_ sender: Any) {
        toolbar.isHidden = false
        styleTb.isHidden = true
        scrollView.isHidden = true
    }
    
    
    //添加图片
    @IBAction func addImage(_ sender: Any) {
        let attributedText = NSMutableAttributedString(attributedString: contentTextView.attributedText!)
        // Add the image as an attachment.
        if let image = UIImage(named: "text_view_attachment") {
            let textAttachment = NSTextAttachment()
            textAttachment.image = image
            textAttachment.bounds = CGRect(origin: CGPoint.zero, size: image.size)
            let textAttachmentString = NSAttributedString(attachment: textAttachment)
            attributedText.append(textAttachmentString)
            contentTextView.attributedText = attributedText
        }
    }
    
    @IBAction func addOther(_ sender: Any) {
        print("=======>添加附件")
    }
    
    //加粗
    @IBAction func bold(_ sender: Any) {
        formatBoldSeletedText()
    }
    
    
    //斜体
    @IBAction func Italic(_ sender: Any) {
        formatItalicSeletedText()
    }
    
    //下划线
    @IBAction func underLine(_ sender: Any) {
        formatUnderlinedSeletedText()
    }
    
    //删除线
    @IBAction func deleteLine(_ sender: Any) {
        formatDeletelinedSeletedText()
    }
    
    
    //获取第一段文本内容：为标题内容
    func setTitleAttribute(){
        let str = self.contentTextView.attributedText.attributedSubstring(from: NSRange(location: 0, length: self.contentTextView.attributedText.length))
        let array = str.string.components(separatedBy: "\n") as NSArray
        
        let attributedText = NSMutableAttributedString(attributedString: contentTextView.attributedText!)
        
        let title = array[0] as! NSString
        
        let tRange = title.range(of: title as String)
        
        attributedText.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22), NSAttributedString.Key.foregroundColor : UIColor.darkText], range: tRange)
        
        contentTextView.attributedText = attributedText
        
    }
    
    
    
    
    
    func keyBoardWillShow(_ note: NSNotification) {
        let userInfo  = note.userInfo! as NSDictionary
        let  keyBoardBounds = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        _ = self.view.convert(keyBoardBounds, to:nil)
        
        _ = styleTb.frame
        _ = toolbar.frame
        
        let deltaY = keyBoardBounds.size.height
        
        let animations:(() -> Void) = {
            
            //字体设置
            self.styleTb.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            self.scrollView.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            //主功能设置
            self.toolbar.transform = CGAffineTransform(translationX: 0,y: -deltaY)
            
            //设置textview高度
            self.contentTextView.contentInset.bottom = deltaY
        }
        
        
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
        }else{
            
            animations()
        }
        
    }
    
    
    
    func keyBoardWillHide(_ note: NSNotification) {
        
        let userInfo  = note.userInfo! as NSDictionary
        
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        let animations:(() -> Void) = {
            //字体设置
            self.styleTb.transform = CGAffineTransform.identity
            self.scrollView.transform = CGAffineTransform.identity
            //主功能设置
            self.toolbar.transform = CGAffineTransform.identity
            
            //设置textview高度
            self.contentTextView.contentInset.bottom = 0
        }
        
        if duration > 0 {
            let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: duration, delay: 0, options:options, animations: animations, completion: nil)
            
        }else{
            
            animations()
        }
        
    }
    
    
    
}



extension ViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText.length == 0{
            DispatchQueue.main.async(execute: {
                textView.selectedRange = NSMakeRange(0, 0)
            })
        }
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.attributedText.length == 0 {
            DispatchQueue.main.async(execute: {
                textView.selectedRange = NSMakeRange(0, 0)
                return
            })
        }
        
        updatingTextRange = textView.selectedRange
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0{
            self.hintLabel.alpha = 0
        }else{
            self.hintLabel.alpha = 1
        }
        
        
        if textView.text.count > 0 {
            let rangeToModify = NSMakeRange((contentTextView.selectedRange.location - 1) > 0 ? contentTextView.selectedRange.location - 1 : 0, 1)
            
            let attributedString = NSMutableAttributedString(string: "")
            attributedString.append(textView.attributedText)
            
            let customFont = UIFont.systemFont(ofSize: 14.0)
            let normalAttributes = [NSAttributedString.Key.font: customFont]
            attributedString.addAttributes(normalAttributes, range: rangeToModify)
            
            self.removeBoldFormat(attributedString, rangeToModify: rangeToModify)
            self.removeItalicFormat(attributedString, rangeToModify: rangeToModify)
            self.removeUnderlineFormat(attributedString, rangeToModify: rangeToModify)
            self.removeDeletelineFormat(attributedString, rangeToModify: rangeToModify)
            
            if isBoldEnabled {
                self.addBoldFormat(attributedString, rangeToModify: rangeToModify)
            }
            
            if isItalicEnabled {
                self.addItalicFormat(attributedString, rangeToModify: rangeToModify)
            }
            
            if isUnderlineEnabled {
                self.addUnderlineFormat(attributedString, rangeToModify: rangeToModify)
            }
            
            if isDeletelineEnabled{
                self.addDeletelineFormat(attributedString, rangeToModify: rangeToModify)
            }
            
            textView.attributedText = attributedString
        }

    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.elementsEqual("\n"){
            setTitleAttribute()
        }
        
        updatingTextRange = range
        
        return true
    }
    
    
    
    
    
    func formatBoldSeletedText() {
        isBoldEnabled = !isBoldEnabled
        if isBoldEnabled { //字体加粗
            if updatingTextRange.length > 0{
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.addBoldFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                contentTextView.selectedRange = rangeToModify
            }
        } else { //取消加粗
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
               
                self.removeBoldFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                contentTextView.selectedRange = rangeToModify
            }
        }
    }
    
    
    func formatItalicSeletedText() {
        isItalicEnabled = !isItalicEnabled
        if isItalicEnabled { //斜体
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.addItalicFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        } else { //取消斜体
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.removeUnderlineFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        }
    }
    
    
    func formatUnderlinedSeletedText() {
        isUnderlineEnabled = !isUnderlineEnabled
        if isUnderlineEnabled { //下划线
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.addUnderlineFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        } else {//取消下划线
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.removeUnderlineFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        }
    }
    
    
    func formatDeletelinedSeletedText() {
        isDeletelineEnabled = !isDeletelineEnabled
        if isDeletelineEnabled{//添加删除线
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.addDeletelineFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        }else{ //取消删除线
            if updatingTextRange.length > 0 {
                let rangeToModify = updatingTextRange
                guard rangeToModify.location < contentTextView.attributedText.length else {
                    return
                }
                
                let attributedString = NSMutableAttributedString(string: "")
                attributedString.append(contentTextView.attributedText)
                
                self.removeDeletelineFormat(attributedString, rangeToModify: rangeToModify)
                contentTextView.attributedText = attributedString
                // Set cursor position after modifying attribute
                contentTextView.selectedRange = rangeToModify
            }
        }
        
    }
    
}


extension UIFont{
    
    func withTraits(_ traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor
            .withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(.traitBold, .traitItalic)
    }
    
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}


// MARK: with text style
extension ViewController{
    //MARK: bold
    func addBoldFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        let customFont = UIFont.systemFont(ofSize: 14.0)
        let boldAttributes = [NSAttributedString.Key.font: customFont.withTraits(.traitBold)]
        attributedString.addAttributes(boldAttributes, range: rangeToModify)
        return attributedString
    }
    
    func removeBoldFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.enumerateAttributes(in: rangeToModify, options: []) { (attributes, range, _) -> Void in
            for (attribute, object) in attributes {
                if let font = object as? UIFont {
                    if attribute == NSAttributedString.Key.font && font.isBold {
                        attributedString.removeAttribute(attribute, range: range)
                        let customFont = UIFont.systemFont(ofSize: 14.0)
                        let normalAttributes = [NSAttributedString.Key.font: customFont]
                        attributedString.addAttributes(normalAttributes, range: range)
                        break
                    }
                }
            }
        }
        return attributedString
    }
    
    
    //MARK: italic
    func addItalicFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        let customFont = UIFont.italicSystemFont(ofSize: 14.0)
        let italicAttributes = isBoldEnabled ? [NSAttributedString.Key.font: customFont.withTraits(.traitBold, .traitItalic)] : [NSAttributedString.Key.font: customFont.withTraits(.traitItalic)]
        attributedString.addAttributes(italicAttributes, range: rangeToModify)
        return attributedString
    }
    
    func removeItalicFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.enumerateAttributes(in: rangeToModify, options: []) { (attributes, range, _) -> Void in
            for (attribute, object) in attributes {
                if let font = object as? UIFont {
                    if attribute == NSAttributedString.Key.font && font.isItalic {
                        attributedString.removeAttribute(attribute, range: range)
                        let customFont = UIFont.systemFont(ofSize: 14.0)
                        let normalAttributes = [NSAttributedString.Key.font: customFont]
                        attributedString.addAttributes(normalAttributes, range: range)
                        break
                    }
                }
            }
        }
        return attributedString
    }
    
    
    //MARK: underline
    func addUnderlineFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: rangeToModify)
        return attributedString
    }
    
    func removeUnderlineFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.enumerateAttributes(in: rangeToModify, options: []) { (attributes, range, _) -> Void in
            var mutableAttributes = attributes
            mutableAttributes.removeValue(forKey: NSAttributedString.Key.underlineStyle)
            attributedString.setAttributes(mutableAttributes, range: rangeToModify)
        }
        return attributedString
    }
    
    
    //MARK: deleteline
    func addDeletelineFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: rangeToModify)
        return attributedString
    }
    
    
    func removeDeletelineFormat(_ attributedString: NSMutableAttributedString, rangeToModify: NSRange) -> NSAttributedString {
        attributedString.enumerateAttributes(in: rangeToModify, options: []) { (attributes, range, _) -> Void in
            var mutableAttributes = attributes
            mutableAttributes.removeValue(forKey: NSAttributedString.Key.strikethroughStyle)
            attributedString.setAttributes(mutableAttributes, range: rangeToModify)
        }
        return attributedString
    }
    
}





