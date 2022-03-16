import SwiftUI
import CoreBluetooth

struct CharacteristicView: View {
    @EnvironmentObject var bleManager: BleManager
    var service: CBService
    var characteristic: CBCharacteristic
    @State var writeValue: String = ""

    var body: some View {
        Form {
            if characteristic.properties.contains(.read) {
                Section("Read") {
                    Button("Read") {
                        // TODO: Read
                    }
                }
            }
            if characteristic.properties.contains(.write) {
                Section("Write") {
                    TextField("value", text: $writeValue)
                        .onSubmit {
                            // TODO: Write
                        }
                }
            }
            if characteristic.properties.contains(.notify) {
                Section("Notify") {
                    Button("Start Observation") {
                        // TODO: Notify
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(characteristic.uuid.uuidString)
                    .foregroundColor(.cyan)
            }
        }
    }
}

//struct CharacteristicView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacteristicView(characteristicId: UUID())
//    }
//}
