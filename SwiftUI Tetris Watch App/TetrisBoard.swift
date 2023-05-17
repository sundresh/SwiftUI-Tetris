//
//  TetrisBoard.swift
//  SwiftUI Tetris App
//
//  Created by Sameer Sundresh on 5/13/23.
//

import Foundation

enum TetrisBlockColor {
    case empty
    case red
    case orange
    case yellow
    case green
    case lightBlue
    case darkBlue
    case purple
}

extension [TetrisBlockColor] {
    var isFullRow: Bool {
        allSatisfy { $0 != .empty }
    }
}

enum TetrisError: Error {
    case pieceDoesNotFit
    case gameIsOver
    case gameIsPaused
}

class TetrisBoard: ObservableObject {
    static let width = 10
    static let height = 20

    static func emptyStaticBoard() -> [[TetrisBlockColor]] {
        Array(repeating: Array(repeating: .empty, count: TetrisBoard.width), count: TetrisBoard.height)
    }

    @Published private(set) var movingPiece: TetrisPiece
    @Published private(set) var nextMovingPiece: TetrisPiece
    @Published private(set) var staticBoard: [[TetrisBlockColor]] = emptyStaticBoard()
    @Published private(set) var isGameOver: Bool = false
    /// When isPaused is true, non-private methods that modify the state of the game are disabled
    /// and throw exceptions. The game will start off paused, so the user interface will need to
    /// unpause it to start the game.
    @Published var isPaused: Bool = true

    init() {
        movingPiece = Self.randomTetrisPiece()
        nextMovingPiece = Self.randomTetrisPiece()
    }

    /// Initialize a random Tetris piece. Attempts to avoid picking cerrtain shapes, as specified
    /// in the `avoid` array: if there are `n` elements in the array, we pick a random shape up to
    /// `n` times, to try to find one that is not in the array. This avoids too much repetition
    /// while still allowing some repetition. (I think the real Tetris actually shuffles the next
    /// batch of pieces, rather than doing this.)
    private static func randomTetrisPiece(avoid shapesToAvoid: [TetrisPiece.Shape] = []) -> TetrisPiece {
        var randomShape = TetrisPiece.Shape.allCases.randomElement()!
        var numTries = 1
        while numTries <= shapesToAvoid.count && shapesToAvoid.contains(randomShape) {
            randomShape = TetrisPiece.Shape.allCases.randomElement()!
            numTries += 1
        }
        return TetrisPiece(x: 4, y: 0, rotation: .rot0deg, shape: randomShape)
    }

    private func fits(tetrisPiece: TetrisPiece) -> Bool {
        for (x, y) in tetrisPiece.blocks {
            if x < 0 || x >= TetrisBoard.width || y >= TetrisBoard.height
                || y >= 0 && staticBoard[y][x] != .empty {
                return false
            }
        }
        return true
    }

    private func add(tetrisPiece: TetrisPiece) throws {
        guard fits(tetrisPiece: tetrisPiece) else {
            throw TetrisError.pieceDoesNotFit
        }
        for (x, y) in tetrisPiece.blocks {
            if y >= 0 {
                staticBoard[y][x] = tetrisPiece.color
            }
        }
    }

    /// Attempt to rotate the currently moving piece 90 degrees to the left.
    func rotatePiece() throws {
        // User input should not be possible when the game is paused.
        guard !isPaused else { throw TetrisError.gameIsPaused }

        if isGameOver {
            throw TetrisError.gameIsOver
        }
        var copyOfMovingPiece = movingPiece
        copyOfMovingPiece.rotation = copyOfMovingPiece.rotation.rotateRight()
        if fits(tetrisPiece: copyOfMovingPiece) {
            movingPiece = copyOfMovingPiece
        }
    }

    /// Attempt to move the currently moving piece one block to the left.
    func movePieceLeft() throws {
        // User input should not be possible when the game is paused.
        guard !isPaused else { throw TetrisError.gameIsPaused }

        if isGameOver {
            throw TetrisError.gameIsOver
        }
        var copyOfMovingPiece = movingPiece
        copyOfMovingPiece.x -= 1
        if fits(tetrisPiece: copyOfMovingPiece) {
            movingPiece = copyOfMovingPiece
        }
    }

    /// Attempt to move the currently moving piece one block to the right.
    func movePieceRight() throws {
        // User input should not be possible when the game is paused.
        guard !isPaused else { throw TetrisError.gameIsPaused }

        if isGameOver {
            throw TetrisError.gameIsOver
        }
        var copyOfMovingPiece = movingPiece
        copyOfMovingPiece.x += 1
        if fits(tetrisPiece: copyOfMovingPiece) {
            movingPiece = copyOfMovingPiece
        }
    }

    /// Attempt to move the currently moving piece one block down. If it can't move down, add it
    /// to the board and select a new moving piece.
    func dropPieceOnce() throws -> Bool {
        // User input should not be possible when the game is paused.
        // While it is possible for a scheduled auto-drop event to occur, the timer handler will
        // have to deal with the fact that it could get an  exception if the game is paused.
        guard !isPaused else { throw TetrisError.gameIsPaused }

        if isGameOver {
            throw TetrisError.gameIsOver
        }
        var copyOfMovingPiece = movingPiece
        copyOfMovingPiece.y += 1
        if fits(tetrisPiece: copyOfMovingPiece) {
            movingPiece = copyOfMovingPiece
            return false
        } else {
            try add(tetrisPiece: movingPiece)
            clearFullRows()
            if !fits(tetrisPiece: nextMovingPiece) {
                isGameOver = true
            }
            let previousShape = movingPiece.shape
            let currentShape = nextMovingPiece.shape
            movingPiece = nextMovingPiece
            nextMovingPiece = Self.randomTetrisPiece(avoid: [previousShape, currentShape])
            return true
        }
    }

    // TODO: Animate line clears
    private func clearFullRows() {
        var newStaticBoard = Self.emptyStaticBoard()
        var newRow = TetrisBoard.height - 1
        for oldRow in (0..<TetrisBoard.height).reversed() {
            if !staticBoard[oldRow].isFullRow {
                newStaticBoard[newRow] = staticBoard[oldRow]
                newRow -= 1
            }
        }
        staticBoard = newStaticBoard
    }
}
