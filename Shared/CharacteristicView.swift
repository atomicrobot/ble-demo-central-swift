import SwiftUI
import CoreBluetooth

struct CharacteristicView: View {
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var bleManager: BleManager
    var service: CBService
    var characteristic: CBCharacteristic
    @State var writeValue: String = ""

    var body: some View {
        Form {
            if characteristic.properties.contains(.read) {
                Section("Read") {
                    Button("Read") {
                        bleManager.readValue(characteristic: characteristic)
                    }
                }
            }
            if characteristic.properties.contains(.write) {
                Section("Write") {
                    TextField("value", text: $writeValue)
                        .onSubmit {
                            guard let data = writeValue.data(using: .utf8) else { return }
                            bleManager.write(value: data, to: characteristic)
                        }
                }
            }
            if characteristic.properties.contains(.notify) {
                Section("Notify") {
                    Button("Start Observation") {
                        bleManager.subscribeToNotifications(characteristic: characteristic)
                    }
                }
            }
            if characteristic.properties.contains(.notify)
                || characteristic.properties.contains(.read) {
                Section("Read/Notify Value") {
                    Text(bleManager.readValue)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(characteristic.uuid.uuidString)
                    .foregroundColor(.cyan)
            }
        }
        .onChange(of: isPresented) { newValue in
            if !newValue {
                bleManager.unsubscribeToNotifications(characteristic: characteristic)
                bleManager.readValue = ""
            }
        }
    }
}

//struct CharacteristicView_Previews: PreviewProvider {
//    static var previews: some View {
//        CharacteristicView(characteristicId: UUID())
//    }
//}
