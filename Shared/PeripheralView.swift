import Foundation
import SwiftUI
import CoreBluetooth

struct PeripheralView: View {
    @EnvironmentObject var bleManager: BleManager
    var peripheralId: UUID
    
    var body: some View {
        List(bleManager.servicesPublisher, id: \.uuid) { service in
            Section(service.uuid.uuidString) {
                if let characteristics = service.characteristics,
                   !characteristics.isEmpty {
                    ForEach(characteristics, id: \.uuid) { characteristic in
                        Text(characteristic.uuid.uuidString)
                    }
                } else {
                    Text("No characteristics")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(peripheralId.uuidString)
                    .foregroundColor(.cyan)
            }
        }
        .onAppear {
            bleManager.stopScan()
            bleManager.connect(to: peripheralId)
        }
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView(peripheralId: UUID())
            .environmentObject(BleManager())
            .preferredColorScheme(.dark)
    }
}
