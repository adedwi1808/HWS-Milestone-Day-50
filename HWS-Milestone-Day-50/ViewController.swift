//
//  ViewController.swift
//  HWS-Milestone-Day-50
//
//  Created by Ade Dwi Prayitno on 01/02/24.
//

import UIKit

class ViewController: UITableViewController {
    var posts = [PostModel]()
    var defaults: UserDefaults = UserDefaults.standard
    var newPost: PostModel = PostModel(fileName: "", caption: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Milestone Day 50"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPost))
        
        performSelector(inBackground: #selector(loadListOfPosts), with: nil)
        
        print(posts)
    }
    
    @objc func loadListOfPosts() {
        if let localePosts = defaults.object(forKey: "posts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                posts = try jsonDecoder.decode([PostModel].self, from: localePosts)
            } catch {
                print("fail to load people data")
            }
        }
    }
    
    @objc func shareTapped() {
        
        let vc = UIActivityViewController(activityItems: ["Coba Cek Aplikasi Ini, Keren bangettt !!!"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(posts) {
            defaults.setValue(posts, forKey: "posts")
        } else {
            print("Fail to save posts.")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Post", for: indexPath)
        
        cell.textLabel?.text = posts[indexPath.row].caption
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let data = posts[indexPath.row]
            vc.data = data
            vc.title = data.fileName
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {
    
    @objc func addNewPost() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        newPost.fileName = imageName
        dismiss(animated: true)
        setPostCaption()
    }
    
    
    func setPostCaption() {
        let ac = UIAlertController(title: "Set Caption", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac ] _ in
            guard
                let self,
                let newValue = ac?.textFields?[0].text
            else { return }
            
            newPost.caption = newValue
            
            self.save()
            posts.append(newPost)
            tableView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return path[0]
    }
}
