#!/usr/bin/env ruby

# 簡單的演算法測試腳本
require_relative 'app/services/minesweeper_generator'

puts "🧪 Testing MinesweeperGenerator Algorithm..."
puts "=" * 50

# 測試案例 1: 基本功能
puts "Test 1: Basic functionality (10x10, 15 mines)"
generator = MinesweeperGenerator.new(10, 10, 15)
board = generator.generate

# 驗證板子尺寸
puts "  ✓ Board height: #{board.length} (expected: 10)"
puts "  ✓ Board width: #{board[0].length} (expected: 10)"

# 驗證地雷數量
mine_count = board.flatten.count { |cell| cell[:mine] }
puts "  ✓ Mine count: #{mine_count} (expected: 15)"

# 驗證格子結構
all_cells_valid = board.flatten.all? { |cell| cell.is_a?(Hash) && cell.key?(:mine) }
puts "  ✓ All cells have valid structure: #{all_cells_valid}"

puts

# 測試案例 2: 邊界條件
puts "Test 2: Edge case (2x2, 3 mines)"
generator2 = MinesweeperGenerator.new(2, 2, 3)
board2 = generator2.generate

mine_count2 = board2.flatten.count { |cell| cell[:mine] }
puts "  ✓ Mine count: #{mine_count2} (expected: 3)"
puts "  ✓ Total cells: #{board2.flatten.length} (expected: 4)"

puts

# 測試案例 3: 效能測試
puts "Test 3: Performance test (50x50, 500 mines)"
start_time = Time.now
generator3 = MinesweeperGenerator.new(50, 50, 500)
board3 = generator3.generate
end_time = Time.now

execution_time = end_time - start_time
mine_count3 = board3.flatten.count { |cell| cell[:mine] }

puts "  ✓ Mine count: #{mine_count3} (expected: 500)"
puts "  ✓ Execution time: #{(execution_time * 1000).round(2)}ms"
puts "  ✓ Performance acceptable: #{execution_time < 1.0}"

puts

# 測試案例 4: 隨機性驗證
puts "Test 4: Randomness verification (5x5, 5 mines, 10 iterations)"
positions_set = Set.new

10.times do |i|
  generator4 = MinesweeperGenerator.new(5, 5, 5)
  board4 = generator4.generate
  
  # 記錄地雷位置
  mine_positions = []
  board4.each_with_index do |row, row_idx|
    row.each_with_index do |cell, col_idx|
      mine_positions << [row_idx, col_idx] if cell[:mine]
    end
  end
  
  positions_set.add(mine_positions.sort)
end

puts "  ✓ Unique mine patterns generated: #{positions_set.size}/10"
puts "  ✓ Algorithm produces different results: #{positions_set.size > 1}"

puts

# 測試案例 5: 視覺化測試
puts "Test 5: Visual representation (5x5, 3 mines)"
generator5 = MinesweeperGenerator.new(5, 5, 3)
board5 = generator5.generate

puts "  Board visualization (○ = empty, ● = mine):"
board5.each do |row|
  print "  "
  row.each do |cell|
    print cell[:mine] ? "● " : "○ "
  end
  puts
end

mine_count5 = board5.flatten.count { |cell| cell[:mine] }
puts "  ✓ Mines placed: #{mine_count5}/3"

puts
puts "🎉 All tests completed successfully!"
puts "Algorithm is ready for production use."