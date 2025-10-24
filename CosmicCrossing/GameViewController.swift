import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func loadView() {
        // Create SKView programmatically instead of using storyboard
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else {
            print("ERROR: View is not an SKView")
            return
        }

        // Create and present the game scene
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill

        // Present the scene
        view.presentScene(scene)

        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
