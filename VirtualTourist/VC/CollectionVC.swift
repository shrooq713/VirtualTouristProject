import UIKit
import MapKit
import CoreData

class CollectionVC: UIViewController ,NSFetchedResultsControllerDelegate{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var context: NSManagedObjectContext{
        return DataController.shared.viewContext
    }
    var doWeHavePhotos : Bool {
        if fetchedResultsController.fetchedObjects?.count == 0{return false}else{return true}
    }
    var pin:Pin!
    var pageNum = 1
    var deletAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUp()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    func setUp() {
        let fetchReq : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchReq.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            if doWeHavePhotos{update(processing: false)}else{newCollectionButtonAction(self)}
        } catch{
            fatalError()
        }
    }
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        update(processing: true)
        if doWeHavePhotos{
            deletAll=true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            deletAll = false
        }
            API.get(with : pin.coordinate, pageNum: pageNum){(url, error, errorMessage) in
                DispatchQueue.main.async{
                    self.update(processing: false)
//                    guard (error == nil) && (errorMessage == nil) else{
//                        self.alert(userMessage: error?.localizedDescription ?? errorMessage!)
//                        return
//                    }
                    if error != nil && errorMessage != nil{
                        self.alert(userMessage: error?.localizedDescription ?? errorMessage!)
                    }
                    guard let url = url, !url.isEmpty else{
                        self.label.isHidden = false
                        return
                    }
                    for url in url{
                        let photo = Photo(context: self.context)
                        photo.imageURL=url
                        photo.pin = self.pin
                    }
                }
                try? self.context.save()
            }
        pageNum += 1
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let indexPath = indexPath, type == .delete && !deletAll{
            collectionView.deleteItems ( at : [indexPath ])
            return
        }
        if let indexPath = indexPath, type == .insert{
            collectionView.insertItems(at: [indexPath])
            return
        }
        if type != .update {
            collectionView.reloadData()
        }
    }
    func update(processing: Bool) {
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            newCollectionButton.title = ""
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
            newCollectionButton.title = "New Collection"
        }
    }
}

extension CollectionVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    var interItemSpacing: CGFloat{
        return 1
    }
    var numberOfItemsInRow: CGFloat{
        return 3
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let image = fetchedResultsController.object(at: indexPath)
        cell.imageView.setPhoto(image)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalInterItemSpaces = (numberOfItemsInRow - 1) * interItemSpacing
        let collectionwidth = collectionView.frame.width - totalInterItemSpaces
        let itemWidth =  collectionwidth/numberOfItemsInRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
