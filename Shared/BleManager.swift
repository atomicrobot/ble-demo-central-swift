import Combine
import CoreBluetooth
import Foundation

struct PeripheralWrapper: Hashable, Equatable {
    var peripheral: CBPeripheral
    var rssi: NSNumber

    func hash(into hasher: inout Hasher) {
        hasher.combine(peripheral)
    }

    static func ==(lhs: PeripheralWrapper, rhs: PeripheralWrapper) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}

class BleManager: NSObject, ObservableObject {
    lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    private var foundPeripheralsSubject = CurrentValueSubject<Set<PeripheralWrapper>, Never>(Set())
    private var foundPeripheralSubject = PassthroughSubject<PeripheralWrapper, Never>()
    @Published var peripheralsPublisher = Set<PeripheralWrapper>()
    @Published var servicesPublisher = [CBService]()
    @Published var centralState = CBManagerState.unknown
    var cancellables = Set<AnyCancellable>()

    let formatter: ISO8601DateFormatter

    override init() {
        formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        super.init()

        foundPeripheralsSubject
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .assign(to: &$peripheralsPublisher)

        foundPeripheralSubject
            .combineLatest(foundPeripheralsSubject) { peripheral, peripherals -> Set<PeripheralWrapper> in
                var mutatedPeripherals = peripherals
                mutatedPeripherals.update(with: peripheral)

                return mutatedPeripherals
            }
            .sink(receiveValue: { [unowned self] peripherals in
                foundPeripheralsSubject.send(peripherals)
            })
            .store(in: &cancellables)
    }

    func startCentral() {
        _ = centralManager
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: nil,
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(to uuid: UUID) {
        let wrapper = peripheralsPublisher.first { $0.peripheral.identifier == uuid }
        guard let peripheral = wrapper?.peripheral else { return }

        peripheral.delegate = self
        print("\(formatter.string(from: Date())) Starting connection")
        centralManager.connect(peripheral, options: nil)
    }
}

extension BleManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralState = central.state
        // TODO: Add comments explaining the states
        switch central.state {
        case .unknown:
            print("The state is .unknown")
        case .resetting:
            print("The state is .resetting")
        case .unsupported:
            print("The state is .unsupported")
        case .unauthorized:
            print("The state is .unauthorized")
        case .poweredOff:
            print("The state is .poweredOff")
        case .poweredOn:
            print("The state is .poweredOn")
        @unknown default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("\(formatter.string(from: Date())) Found peripheral \(peripheral.identifier)")
        foundPeripheralSubject.send(PeripheralWrapper(peripheral: peripheral, rssi: RSSI))
    }

    // Found a peripheral but services are nil so we need to discover them
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\(formatter.string(from: Date())) Connected to peripheral \(peripheral.identifier) \(peripheral.name)")

        peripheral.discoverServices(nil)
    }
}

extension BleManager: CBPeripheralDelegate {
    // Found all services but the characteristics are nil so we need to discover them
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("\(formatter.string(from: Date())) didDiscoverServices - \(peripheral.services?.count)")
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // Found all characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("\(formatter.string(from: Date())) didDiscoverCharacteristicsFor service \(service.uuid) characteristics \(service.characteristics)")
        var services = servicesPublisher
        services.append(service)
        servicesPublisher = services
    }
}
