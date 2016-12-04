import QtQuick 2.5
import "syllable.js" as Syl
pragma Singleton
QtObject {
    id : rootObject
    function count(word) {
        return Syl.syllable(word)
    }

    function countSentence(sentence) {
        var words = sentence.split(" ");
        var sum = 0;
        words.forEach(function(word){ sum+= Syl.syllable(word) })
        return sum;
    }


}
