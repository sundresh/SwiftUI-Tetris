//
//  ContentView.swift
//  SwiftUI Tetris App
//
//  Created by Sameer Sundresh on 5/13/23.
//

import SwiftUI

extension TetrisBlockColor {
    var color: Color {
        switch self {
        case .empty:     return .black
        case .red:       return .red
        case .orange:    return .orange
        case .yellow:    return .yellow
        case .green:     return .green
        case .lightBlue: return .cyan
        case .darkBlue:  return .blue
        case .purple:    return .purple
        }
    }
}

enum SwipeState {
    case notSwiping
    case swipeCancelled
    case horizontalSwipe
    case verticalSwipe
}

struct TetrisContentView: View {
    // TODO: Set dimensions based on screen size
    static let blockSize: CGFloat = 9
    static let blockSpacing: CGFloat = 0.5
    static let borderPadding: CGFloat = 3
    static let horizontalOffset: CGFloat = -17
    static let swipeLengthForOneBlock: CGFloat = 3*blockSize
    static let minRatioBetweenSwipeAxisAndOtherAxis: CGFloat = 2

    @ObservedObject var tetrisBoard: TetrisBoard = TetrisBoard()
    @State var currentSwipeAxis: SwipeState = .notSwiping
    @State var swipeDistanceAlreadyAccountedFor: CGFloat = 0

    var timer: Timer? = nil

    init() {
        let tb = tetrisBoard
        timer = Timer(timeInterval: 1.0, repeats: true) { t in
            let _ = try? tb.dropPieceOnce()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                let dx = v.translation.width
                let dy = v.translation.height

                if currentSwipeAxis == .notSwiping {
                    if abs(dx) >= abs(dy) * Self.minRatioBetweenSwipeAxisAndOtherAxis {
                        currentSwipeAxis = .horizontalSwipe
                    } else if abs(dy) >= abs(dx) * Self.minRatioBetweenSwipeAxisAndOtherAxis {
                        currentSwipeAxis = .verticalSwipe
                    }
                    swipeDistanceAlreadyAccountedFor = 0
                }

                switch currentSwipeAxis {
                case .notSwiping:
                    break
                case .swipeCancelled:
                    break
                case .horizontalSwipe:
                    while abs(dx - swipeDistanceAlreadyAccountedFor) >= Self.swipeLengthForOneBlock {
                        if dx > swipeDistanceAlreadyAccountedFor {
                            try? tetrisBoard.movePieceRight()
                            swipeDistanceAlreadyAccountedFor += Self.swipeLengthForOneBlock
                        } else {
                            try? tetrisBoard.movePieceLeft()
                            swipeDistanceAlreadyAccountedFor -= Self.swipeLengthForOneBlock
                        }
                    }
                case .verticalSwipe:
                    var numDrops = 0
                    while abs(dy - swipeDistanceAlreadyAccountedFor) >= Self.swipeLengthForOneBlock {
                        if dy > swipeDistanceAlreadyAccountedFor {
                            if (try? tetrisBoard.dropPieceOnce()) == false {
                                swipeDistanceAlreadyAccountedFor += Self.swipeLengthForOneBlock
                                numDrops += 1
                            } else {
                                currentSwipeAxis = .swipeCancelled
                                break
                            }
                        }
                    }
                    if numDrops >= 2 {  // TODO: measure actual velocity to determine when to hard drop
                        while currentSwipeAxis != .swipeCancelled {
                            if (try? tetrisBoard.dropPieceOnce()) == false {
                            } else {
                                currentSwipeAxis = .swipeCancelled
                            }
                        }
                    }
                }
            }
            .onEnded { _ in
                currentSwipeAxis = .notSwiping
                swipeDistanceAlreadyAccountedFor = 0
            }
    }

    var body: some View {
        ZStack {
            let movingPieceBlocks = tetrisBoard.movingPiece.blocks
            Grid(horizontalSpacing: Self.blockSpacing, verticalSpacing: Self.blockSpacing) {
                ForEach(0..<20) { row in
                    GridRow {
                        ForEach(0..<10) { col in
                            (movingPieceBlocks.contains((col, row)) ? tetrisBoard.movingPiece.color.color : tetrisBoard.staticBoard[row][col].color)
                                .frame(width: Self.blockSize, height: Self.blockSize)
                        }
                    }
                }
            }.padding(Self.borderPadding)
            .border(.gray)
            .onTapGesture {
                try? tetrisBoard.rotatePiece()
            }.gesture(swipeGesture)
            if tetrisBoard.isGameOver {
                Text("GAME OVER")
                    .background(.black.opacity(0.35))
            }
            // TODO: Show next piece, number of lines completed, and score
        }.offset(x: Self.horizontalOffset)
    }
}

struct TetrisContentView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisContentView()
    }
}
