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
}

class TetrisBoard: ObservableObject {
    static let width = 10
    static let height = 20

    static func emptyStaticBoard() -> [[TetrisBlockColor]] {
        Array(repeating: Array(repeating: .empty, count: TetrisBoard.width), count: TetrisBoard.height)
    }

    @Published private(set) var movingPiece: TetrisPiece
    @Published private(set) var staticBoard: [[TetrisBlockColor]] = emptyStaticBoard()
    @Published private(set) var isGameOver: Bool = false

    init() {
        movingPiece = Self.randomTetrisPiece()
    }

    private static func randomTetrisPiece() -> TetrisPiece {
        let randomShape = TetrisPiece.Shape.allCases.randomElement()!
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
        if isGameOver {
            throw TetrisError.gameIsOver
        }
        var copyOfMovingPiece = movingPiece
        copyOfMovingPiece.rotation = copyOfMovingPiece.rotation.rotateLeft()
        if fits(tetrisPiece: copyOfMovingPiece) {
            movingPiece = copyOfMovingPiece
        }
    }

    /// Attempt to move the currently moving piece one block to the left.
    func movePieceLeft() throws {
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
            let newMovingPiece = Self.randomTetrisPiece()
            if !fits(tetrisPiece: newMovingPiece) {
                isGameOver = true
            }
            movingPiece = newMovingPiece
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
