import Felgo 3.0
import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: gameSound
    Audio {
      id: moveBlock
      source: "../../assets/snd/NFF-switchy.wav"
    }

    Audio {
      id: moveBlockBack
      source: "../../assets/snd/NFF-switchy-02.wav"
    }

    Audio {
      id: fruitClear
      source: "../../assets/snd/NFF-fruit-collected.wav"
    }

    Audio {
      id: overloadClear
      source: "../../assets/snd/NFF-fruit-appearance.wav"
    }

    Audio {
      id: upgrade
      source: "../../assets/snd/NFF-upgrade.wav"
    }

    // text (overlay) audios
    Audio {
      id: overloadSound
      autoPlay: false
      source: "../../assets/snd/texts/JuicyOverload.wav"
    }

    Audio {
      id: fruitySound
      autoPlay: false
      source: "../../assets/snd/texts/Fruity.wav"
    }

    Audio {
      id: sweetSound
      autoPlay: false
      source: "../../assets/snd/texts/Sweet.wav"
    }

    Audio {
      id: refreshingSound
      autoPlay: false
      source: "../../assets/snd/texts/Refreshing.wav"
    }

    Audio {
      id: yummySound
      autoPlay: false
      source: "../../assets/snd/texts/Yummy.wav"
    }

    Audio {
      id: deliciousSound
      autoPlay: false
      source: "../../assets/snd/texts/Delicious.wav"
    }

    Audio {
      id: smoothSound
      autoPlay: false
      source: "../../assets/snd/texts/Smooth.wav"
    }

    function playMoveBlock() { moveBlock.stop(); moveBlock.play() }
    function playMoveBlockBack() { moveBlock.stop(); moveBlockBack.play() }
    function playFruitClear() { fruitClear.stop(); fruitClear.play() }
    function playOverloadClear() {  overloadClear.stop(); overloadClear.play() }
    function playUpgrade() { upgrade.stop(); upgrade.play() }

    function playFruitySound() {  fruitySound.stop(); fruitySound.play() }
    function playSweetSound() {  sweetSound.stop(); sweetSound.play() }
    function playRefreshingSound() {  refreshingSound.stop(); refreshingSound.play() }
    function playOverloadSound() {  overloadSound.stop(); overloadSound.play() }
    function playYummySound() {  yummySound.stop(); yummySound.play() }
    function playDeliciousSound() {  deliciousSound.stop(); deliciousSound.play() }
    function playSmoothSound() {  smoothSound.stop(); smoothSound.play() }


}
