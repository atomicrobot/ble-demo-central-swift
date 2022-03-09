import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bleManager: BleManager

    var peripherals: [PeripheralWrapper] {
        bleManager.peripheralsPublisher.sorted { $0.peripheral.name ?? "Unnamed" > $1.peripheral.name ?? "Unnamed" }
    }

    var centralIsUnavailable: Bool {
        bleManager.centralState != .poweredOn
    }

    var isScanning: Bool {
        bleManager.centralManager.isScanning
    }

    var buttonText: String {
        isScanning ? "Stop Scan" : "Start Scan"
    }

    var body: some View {
        NavigationView{
            VStack {
                Button(buttonText) {
                    if isScanning {
                        bleManager.stopScan()
                    } else {
                        bleManager.startScan()
                    }
                }
                .disabled(centralIsUnavailable)
                .tint(.cyan)
                .buttonStyle(.bordered)
                .controlSize(.large)

                List(peripherals, id: \.peripheral.identifier) { wrapper in
                    NavigationLink {
                        PeripheralView(peripheralId: wrapper.peripheral.identifier)
                    } label: {
                        PeripheralRow(name: wrapper.peripheral.name ?? "Unnamed",
                                      identifier: wrapper.peripheral.identifier.uuidString,
                                      rssi: String(describing: wrapper.rssi))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Bluetooth Low Energy!")
                        .font(.largeTitle)
                        .foregroundColor(.cyan)
                }
            }
            .onAppear {
                bleManager.startCentral()
            }
        }
    }
}

struct PeripheralRow: View {
    let name: String
    let identifier: String
    let rssi: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                Text(identifier)
                    .font(.footnote)
            }
            Spacer()
            Text(rssi)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BleManager())
            .preferredColorScheme(.dark)
    }
}

struct PeripheralRow_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralRow(name: "Hello World",
                      identifier: "73CC33AC-D0C2-3D5A-3917-A866B87B9CEB",
                      rssi: "-56")
            .preferredColorScheme(.dark)
    }
}
