// Game constants and configuration
export const GAME_STATUS = {
  PLAYING: 'playing',
  WON: 'won',
  LOST: 'lost'
}

export const CELL_STATUS = {
  HIDDEN: 'hidden',
  REVEALED: 'revealed',
  FLAGGED: 'flagged'
}

export const COLORS = {
  1: '#0000ff',
  2: '#008000', 
  3: '#ff0000',
  4: '#800080',
  5: '#800000',
  6: '#008080',
  7: '#000000',
  8: '#808080'
}

export const CELL_STYLES = {
  hidden: {
    backgroundColor: '#e9ecef',
    border: '2px outset #ddd',
    color: '#000'
  },
  revealed: {
    backgroundColor: '#f8f9fa',
    border: '1px inset #ddd'
  },
  mine: {
    backgroundColor: '#dc3545',
    color: 'white'
  },
  flagged: {
    backgroundColor: '#fff3cd'
  },
  winMine: {
    backgroundColor: '#d4edda'
  }
}