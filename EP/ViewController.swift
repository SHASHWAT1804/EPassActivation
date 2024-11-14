import UIKit
import LocalAuthentication
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Event {
        var name: String
        var date: String
        var time: String
        var image: String
        var latitude: Double
        var longitude: Double
            }

            let events: [Event] = [
                Event(name: "Aaruush", date: "04/11/24", time: "10:00 AM", image: "aaruush", latitude: 37.7749, longitude: -122.4194),
                Event(name: "Milan", date: "05/11/24", time: "10:00 AM", image: "milan", latitude: 34.0522, longitude: -118.2437)
            ]

    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DataTableViewCell else {
            return UITableViewCell()
        }

        let event = events[indexPath.row]
        cell.eventNameLabel.text = event.name
        cell.eventDateLabel.text = event.date
        cell.eventTimeLabel.text = event.time
        cell.eventImageView.image = UIImage(named: event.image)

        // Style the card view
        cell.epassCardView.layer.cornerRadius = 10
        cell.epassCardView.layer.shadowColor = UIColor.black.cgColor
        cell.epassCardView.layer.shadowOpacity = 0.2
        cell.epassCardView.layer.shadowOffset = CGSize(width: 0, height: 2)

        // Set button tag to the current indexPath.row
        cell.activatePassButton.tag = indexPath.row
        cell.activatePassButton.addTarget(self, action: #selector(activatePassTapped(_:)), for: .touchUpInside)

        return cell
    }

    @objc func activatePassTapped(_ sender: UIButton) {
        authenticateUser(for: sender.tag)
    }

    func authenticateUser(for index: Int) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your app"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.showECodePopup(for: index) // Pass the index to show the e-code popup
                    } else {
                        self.showErrorAlert()
                    }
                }
            }
        } else {
            showAlert(title: "Authentication Unavailable", message: "Biometric authentication is not available on this device.")
        }
    }
    func showEventLocationOnMap(for index: Int) {
        let event = events[index]
        if let mapVC = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MAPVC {
            mapVC.eventCoordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
            mapVC.eventName = event.name
            navigationController?.pushViewController(mapVC, animated: true)
        }
    }


    func showECodePopup(for index: Int) {
        let uniqueECode = String(format: "%06d", Int.random(in: 100000...999999))
        let alert = UIAlertController(title: "ePass Activated", message: "Your unique e-code is \(uniqueECode).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.deactivateButton(at: index) // Deactivate the button after OK is clicked
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func deactivateButton(at index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DataTableViewCell {
            // Disable the button
            cell.activatePassButton.isEnabled = false
            cell.activatePassButton.alpha = 0.5 // Fade out visually if desired
        }
    }

    func showErrorAlert() {
        let alert = UIAlertController(title: "Authentication Failed", message: "Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
