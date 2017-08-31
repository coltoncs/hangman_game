//
//  ViewController.swift
//  Hangman
//
//  Created by Colton Sweeney on 8/26/17.
//  Copyright © 2017 coltoncsweeney. All rights reserved.
//

// Tasks:
// --Arrays to hold words and hints : DONE
// --Variable to hold word to guess and word as underscores : DONE
// --Randomize selection of words : DONE
// --Need a way to keep track of # of guesses used : DONE
// --Need a way to guess a letter and process if it's correct : DONE
// --If right, add to word; if wrong, remove a guess, and letter to letter bank : DONE
// --Lose game if you run out of guesses : DONE
// --Win game if you guess every letter : DONE

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var wordToGuessLabel: UILabel!
    @IBOutlet weak var remainingGuessLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var letterBankLabel: UILabel!
    
    let LIST_OF_WORDS : [String] = ["hello", "goodbye", "mammoth", "hangman", "coffee"]
    let LIST_OF_HINTS : [String] = ["greeting", "farewell", "extinct mastodon", "letter guessing game", "caffeinated bevvy"]
    var wordToGuess : String!
    var guessesRemaining : Int!
    let MAX_NUMBER_OF_GUESSES : Int = 5
    var wordAsUnderscores : String!
    var oldRandomNumber : Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inputTextField.delegate = self
        inputTextField.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newWordAction(_ sender: UIButton) {
        reset()
        letterBankLabel.text?.append("LETTER BANK: ")
        let index = choseRandomNumber()
        wordToGuess = LIST_OF_WORDS[index]
        let hint = LIST_OF_HINTS[index]
        hintLabel.text = "Hint: \(hint), \(wordToGuess.characters.count) letters"
        
        for _ in 1...wordToGuess.characters.count {
            wordAsUnderscores.append("_")
        }
        wordToGuessLabel.text = wordAsUnderscores
    }

    func choseRandomNumber() -> Int {
        var newRandNumber : Int = Int(arc4random_uniform(UInt32(LIST_OF_WORDS.count)))
        if newRandNumber == oldRandomNumber {
            newRandNumber = choseRandomNumber()
        } else {
            oldRandomNumber = newRandNumber
        }
        return newRandNumber
    }
    
    func reset() {
        guessesRemaining = MAX_NUMBER_OF_GUESSES
        remainingGuessLabel.text = "\(guessesRemaining!) guesses left"
        wordAsUnderscores = ""
        inputTextField.text?.removeAll()
        letterBankLabel.text?.removeAll()
        inputTextField.isEnabled = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let letterGuessed = textField.text else { return }
        inputTextField.text?.removeAll()
        let currentLetterBank : String = letterBankLabel.text ?? ""
        if currentLetterBank.contains(letterGuessed) {
            return
        } else {
            if wordToGuess.contains(letterGuessed) {
                processCorrectGuess(letterGuessed: letterGuessed)
            } else {
                processIncorrectGuess()
            }
            letterBankLabel.text?.append("\(letterGuessed), ")
        }
    }
    
    func processCorrectGuess(letterGuessed: String) {
        let characterGuessed = Character(letterGuessed)
        for index in wordToGuess.characters.indices {
            if wordToGuess[index] == characterGuessed {
                let endIndex = wordToGuess.index(after: index)
                let charRange = index..<endIndex
                wordAsUnderscores = wordAsUnderscores.replacingCharacters(in: charRange, with: letterGuessed)
                wordToGuessLabel.text = wordAsUnderscores
            }
        }
        if !(wordAsUnderscores.contains("_")) {
            remainingGuessLabel.text = "You won! (-:"
            inputTextField.isEnabled = false
        }
    }
    
    func processIncorrectGuess() {
        guessesRemaining! -= 1
        if (guessesRemaining == 0){
            inputTextField.isEnabled = false
            remainingGuessLabel.text = "You lost! )-:"
        } else {
            remainingGuessLabel.text = "\(guessesRemaining!) guesses left."
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedChars = NSCharacterSet.lowercaseLetters
        let startingLength = textField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        
        if string.isEmpty {
            return true
        } else if newLength == 1 {
            if let _ = string.rangeOfCharacter(from: allowedChars, options: .caseInsensitive) {
                return true
            }
        }
        return false
    }
}

