
import UIKit
import RxSwift
import RxCocoa
import Kingfisher

func cachedFileURL(_ fileName: String) -> URL {
  return FileManager.default
    .urls(for: .cachesDirectory, in: .allDomainsMask)
    .first!
    .appendingPathComponent(fileName)
}

class ActivityController: UITableViewController {

  let repo = "ReactiveX/RxSwift"

  fileprivate let events = Variable<[Event]>([])
  fileprivate let bag = DisposeBag()
  
  private let eventsFileURL = cachedFileURL("events.plist")
  private let modifiedFileURL = cachedFileURL("modified.txt")
  fileprivate let lastModified = Variable<NSString?>(nil)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = repo

    self.refreshControl = UIRefreshControl()
    let refreshControl = self.refreshControl!

    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    let eventsArray = (NSArray(contentsOf: eventsFileURL)
      as? [[String: Any]]) ?? []
    events.value = eventsArray.flatMap(Event.init)
    lastModified.value = try? NSString(contentsOf: modifiedFileURL,
                                       usedEncoding: nil)
    
    refresh()
  }

  func refresh() {
    fetchEvents(repo: repo)
  }

  func fetchEvents(repo: String) {
      let response = Observable.from([repo]).map { urlString -> URL in
        return URL(string: "https://api.github.com/repos/\(urlString)/events")!
      }.map { [weak self] url -> URLRequest in
        var request = URLRequest(url: url)
        if let modifiedHeader = self?.lastModified.value {
          request.addValue(modifiedHeader as String,
                           forHTTPHeaderField: "Last-Modified")
        }
        return request
      }.flatMap { request -> Observable<(response: HTTPURLResponse,data: Data)> in
        return URLSession.shared.rx.response(request: request)
      }.share(replay: 1, scope: SubjectLifetimeScope.forever)
    
      response.filter { response, _ in
          return 200..<300 ~= response.statusCode
      }.map { _, data -> [[String: Any]] in
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data,
                                                                 options: []),
          let result = jsonObject as? [[String: Any]] else {
            return [] }
        return result
      }.filter { objects in
        return objects.count > 0
      }.map { objects in
        objects.flatMap(Event.init)
      }.subscribe(onNext: { [weak self] newEvents in
        self?.processEvents(newEvents)
      }).disposed(by: bag)
    
    response
      .filter {response, _ in
        return 200..<400 ~= response.statusCode
      }.flatMap { response, _ -> Observable<NSString> in
        guard let value = response.allHeaderFields["Last-Modified"]  as?
          NSString else {
            return Observable.never()
        }
        return Observable.just(value)
      }.subscribe(onNext: { [weak self] modifiedHeader in
        guard let strongSelf = self else { return }
        strongSelf.lastModified.value = modifiedHeader
        try? modifiedHeader.write(to: strongSelf.modifiedFileURL, atomically: true,
                                  encoding: String.Encoding.utf8.rawValue)
      })
      .disposed(by: bag)
  }
  
  func processEvents(_ newEvents: [Event]) {
    var updatedEvents = newEvents + events.value
    if updatedEvents.count > 50 {
      updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
    }
    events.value = updatedEvents
    tableView.reloadData()
    
    let eventsArray = updatedEvents.map{ $0.dictionary } as NSArray
    eventsArray.write(to: eventsFileURL, atomically: true)
    
    refreshControl?.endRefreshing()
  }

  // MARK: - Table Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.value.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = events.value[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
    cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
    return cell
  }
}
