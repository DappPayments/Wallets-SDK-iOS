
# Dapp Wallet SDK iOS
[Dapp](https://dapp.mx) es una plataforma de pagos, enfocada en la seguridad de sus usuarios. Este SDK permite la lectura de códigos QR Dapp a wallets electrónicos.

## INSTALACIÓN
Recomendamos utilizar cocoapods para integrar Dapp Wallet SDK
```
platform :ios, '10.0'
pod 'DappWalletMX'
```

## CONFIGURACIÓN
1. Agrega la siguiente instrucción de importación en el **AppDelegate**: 
```swift
import DappWalletMX
```
2. Inicializa el objeto DappWallet reemplazando _your-dapp-api-key_ con tu llave de producción dentro del método **application(_:didFinishLaunchingWithOptions:)**:
```swift
DappWallet.shared.apiKey = "your-dapp-api-key"
```

## OBTENER INFORMACIÓN DE CÓDIGOS QR DAPP

En caso de que el wallet ya cuente con un lector de códigos QR propio, valide y reciba la información de pago del texto obtenido vía el lector

1. Crea una clase (en este ejemplo utilizaremos el viewController al que pertenece lector) que adopte el protocolo **DappWalletDelegate** e implementa sus métodos para obtener la información asociada al código escaneado.
```swift
import DappWalletMX

class ViewController: UIViewController, DappPaymentDelegate {

    //MARK: - DappWalletDelegate
    public func dappWalletSuccess(code: DappCode) {
        //realice las acciones apropiadas con la información obtenida
    }
    
    public func dappWalletFailure(error: DappError) {
    //tu código para manejar el error
    print(error)
    switch error {
    default:
        break
    }
    }
```
2. Una vez obtenido el texto vía el lector de códigos QR, valide y obtenga la información asociada al código.
```swift
let qrTextFromScanner: String = "https://dapp.mx/c/oW9BYXqJ"
if !DappWallet.shared.isValid(DappCode: qrTextFromScanner) {
    //Indique al usuario que no es un código válido
}
DappWallet.shared.readDappCode(code: code, delegate: self) //self == ViewController
```
3. **Dapp Wallet SDK iOS** también es compatible con CoDi. Existen dos funciones que puedes utilizar:
```swift
DappWallet.shared.isValidCodi(qrTextFromScanner) //true or false
DappWallet.shared.getQRType(qrTextFromScanner) //.codi, .dapp, .codiDapp, .unknown
```

## UTILIZAR EL LECTOR DE CÓDIGOS QR DAPP

Las funciones del lector se pueden implementar de dos formas:

 - **Como view controller**:  Más rápido y sencillo. Crea un _DappScannerViewController_ y preséntalo. Éste view controller se encarga de obtener la información de los códigos QR Dapp y de todos los aspectos relacionados con el UX.
 - **Como view** : Más flexible. Crea un _DappScannerView_ que solo se encargará de obtener la información de los códigos QR Dapp. Esto te permite implementar un UX que vaya más acorde con tu aplicación.

Cualquier opción que elijas, es necesario configurar el archivo **info.plist**. Añade la propiedad [_NSCameraUsageDescription_](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW24)  junto con un valor de tipo _string_ describiendo por que tu app requiere del uso de la cámara (Por ej: "Escanea códigos QR"). Este texto se muestra al usuario cuando la app pide permiso para utilizar la cámara por primera vez.

### Integra el lector como view controller

1. Crea una clase (puede ser el view controller que presentará el _DappScannerViewController_) que adopte el protocolo **DappScannerViewControllerDelegate** e implementa sus métodos para recibir información referente a la lectura del código QR.
```swift
import DappWalletMX

class ViewController: UIViewController, DappScannerViewControllerDelegate {

    //MARK: - DappScannerViewControllerDelegate
    func dappScannerViewControllerSuccess(_ viewController: DappScannerViewController, code: DappCode) {
    //realice las acciones apropiadas con la información obtenida
        print(code.id)
    }
    
    func dappScannerViewControllerFailure(_ viewController: DappScannerViewController, error: DappError) {
    //tu código para manejar el error
        print(error)
        switch error {
    default:
        break
    }
    }
```
2. Presenta el _DappScannerViewController_.
```swift
    @IBAction func scanQR(_ sender: Any) {
        let vc = DappScannerViewController(delegate: self) //self == ViewController
        present(vc, animated: true, completion: nil)
    }
```
### Integra el lector como view
1. Crea una clase (puede ser el view controller al que va a pertenecer el _DappScannerView_) que adopte el protocolo **DappScannerViewDelegate** e implementa el método para recibir información referente a la lectura del código QR.
```swift
import DappWalletMX

class ViewController: UIViewController, DappPaymentDelegate {

    //MARK: - DappScannerViewControllerDelegate
    public func dappScannerView(_ dappScannerView: DappScannerView, didChangeStatus status: DappScannerViewStatus) {
        switch status {
        case .isValidatingQR:
        //validando el QR vía https con los servidores Dapp. Realiza las acciones apropiadas en tu aplicación
        case .success(let code):
        //realice las acciones apropiadas con la información obtenida
        case .failed(let e):
            //tu código para manejar el error
        }
    }

```
2. Agrega un _DappScannerView_ a tu view controller vía storyboard o código y asigna el delegate
```swift
    @IBOutlet var scannerView: DappScannerView!

     override public func viewDidLoad() {
        super.viewDidLoad()
        //scannerView = DappScannerView(frame:  CGRect(x: 0, y: 0, width: 100, height: 100))
        //view.addSubview(scannerView)
        scannerView.delegate = self //self == ViewController
    }
```
3. Para empezar escanear, utiliza la función _startScanning_
```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.startScanning()
    }
```
4. Para parar el scanner, utiliza la función _stopScanning_
```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scannerView.startScanning()
    }
```
5. En caso de necesitar saber si el lector está activo utilice la funcion _isScanning_
```swift
scannerView.isScanning()
```

## LICENCIA
[MIT](LICENSE.txt)
