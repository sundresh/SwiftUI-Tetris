//
//  TetrisPiece.swift
//  SwiftUI Tetris App
//
//  Created by Sameer Sundresh on 5/13/23.
//

import Foundation

extension [(Int, Int)] {
    func contains(_ block: (Int, Int)) -> Bool {
        for element in self {
            if block == element {
                return true
            }
        }
        return false
    }
}

struct TetrisPiece: Equatable {
    enum Shape: CaseIterable {
        case O
        case I
        case L
        case J
        case S
        case Z
        case T
    }

    enum Rotation {
        case rot0deg
        case rot90deg
        case rot180deg
        case rot270deg

        func rotateLeft() -> Rotation {
            switch self {
            case .rot0deg: return .rot90deg
            case .rot90deg: return .rot180deg
            case .rot180deg: return .rot270deg
            case .rot270deg: return .rot0deg
            }
        }

        func rotateRight() -> Rotation {
            switch self {
            case .rot0deg: return .rot270deg
            case .rot90deg: return .rot0deg
            case .rot180deg: return .rot90deg
            case .rot270deg: return .rot180deg
            }
        }
    }

    var x: Int
    var y: Int
    var rotation: Rotation
    var shape: Shape

    var color: TetrisBlockColor {
        switch shape {
        case .O: return .yellow
        case .I: return .lightBlue
        case .L: return .orange
        case .J: return .darkBlue
        case .S: return .green
        case .Z: return .red
        case .T: return .purple
        }
    }

    var blocks: [(Int, Int)] {
        return relativeBlocks.map { (dx, dy) in (x + dx, y + dy) }
    }

    var relativeBlocks: [(Int, Int)] {
        switch shape {
        case .O: return [(0, 0), (1, 0),
                         (0, 1), (1, 1)]
        case .I:
            switch rotation {
            case .rot0deg:   fallthrough
            case .rot180deg: return [(0, 0),
                                     (0, 1),
                                     (0, 2),
                                     (0, 3)]
            case .rot90deg:  fallthrough
            case .rot270deg: return [(-1, 1), (0, 1), (1, 1), (2, 1)]
            }
        case .L:
            switch rotation {
            case .rot0deg:   return [                 (1, 0),
                                     (-1, 1), (0, 1), (1, 1)]
            case .rot90deg:  return [(-1, 0), (0, 0),
                                              (0, 1),
                                              (0, 2)]
            case .rot180deg: return [
                                     (-1, 1), (0, 1), (1, 1),
                                     (-1, 2),]
            case .rot270deg: return [         (0, 0),
                                              (0, 1),
                                              (0, 2), (1, 2)]
            }
        case .J:
            switch rotation {
            case .rot0deg:   return [(-1, 0),
                                     (-1, 1), (0, 1), (1, 1)]
            case .rot90deg:  return [         (0, 0),
                                              (0, 1),
                                     (-1, 2), (0, 2)]
            case .rot180deg: return [
                                     (-1, 1), (0, 1), (1, 1),
                                                      (1, 2)]
            case .rot270deg: return [         (0, 0), (1, 0),
                                              (0, 1),
                                              (0, 2)]
            }
        case .S:
            switch rotation {
            case .rot0deg:  fallthrough
            case .rot180deg: return [         (0, 0), (1, 0),
                                     (-1, 1), (0, 1)]
            case .rot90deg:  fallthrough
            case .rot270deg: return [         (0, -1),
                                              (0, 0), (1, 0),
                                                      (1, 1)]
            }
        case .Z:
            switch rotation {
            case .rot0deg:  fallthrough
            case .rot180deg: return [(-1, 0), (0, 0),
                                              (0, 1), (1, 1)]
            case .rot90deg:  fallthrough
            case .rot270deg: return [                 (1, -1),
                                              (0, 0), (1, 0),
                                              (0, 1)]
            }
        case .T:
            switch rotation {
            case .rot0deg:   return [         (0, 0),
                                     (-1, 1), (0, 1), (1, 1)]
            case .rot90deg:  return [         (0, 0),
                                     (-1, 1), (0, 1),
                                              (0, 2)]
            case .rot180deg: return [
                                     (-1, 1), (0, 1), (1, 1),
                                              (0, 2)]
            case .rot270deg: return [(0, 0),
                                     (0, 1), (1, 1),
                                     (0, 2)]
            }
        }
    }
}
