//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 02.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class MapVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins :[Pin] = []
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var context: NSManagedObjectContext{
        return DataController.shared.viewContext
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUp()
        update()
        }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    func setUp() {
        let fetchReq : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false),]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            update()
        } catch{
            fatalError()
        }
        fetchedResultsController.fetchedObjects?.forEach({ (pin) in
            pins.append(pin)
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Photo"{
            let photo = segue.destination as! CollectionVC
            photo.pin = sender as? Pin
        }
    }

    @IBAction func AddPin(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = locationCoordinate
//        annotaion.title = "Title"
//        annotaion.subtitle = "SubTitle"
        
        self.mapView.addAnnotation(annotaion)
        let pin = Pin(context: self.context)
        pin.latitude = locationCoordinate.latitude
        pin.longitude = locationCoordinate.longitude
        pin.creationDate = Date()
        
        pins.append(pin)
        
        try?context.save()
        
        
        
    }
    
    
    func mangeLocation(newLocation: CLLocation!){
        let region = MKCoordinateRegion(center: newLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setRegion(region, animated: true)
        
    }

    
    func update(){
        guard let pins = fetchedResultsController.fetchedObjects else{
            return
        }
    
        for pin in pins {
            if mapView.annotations.contains(where: {pin.compare(to: $0.coordinate)}){
                continue
            }
            let coordinate = pin.coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    func reload(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        update()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let pins = fetchedResultsController.fetchedObjects?.filter{$0.compare(to: view.annotation!.coordinate)}.first!
        let pin = pins.filter{$0.compare(to: view.annotation!.coordinate)}.first
            performSegue(withIdentifier: "Photo", sender: pin)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
        annotationView.image = UIImage(named: "pin")
        annotationView.canShowCallout = true
        return annotationView
    }

}
