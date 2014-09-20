#!/usr/bin/env ruby

require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn/table'
require 'json'


# spit out coordinates for next textbox for grid 
class Gridder
  @x = -1
  @y = 1

  class << self
    attr_accessor :x
    attr_accessor :y
  end

  def next
    max_x = 7
    max_y = 11

    self.class.x += 1

    if self.class.x == max_x
      self.class.x = 0
      self.class.y += 1
    end

    if self.class.y == max_y
      self.class.y = 1
    end

    return [self.class.x, self.class.y]

  end
end



def json_file(filename)
  JSON.parse IO.read(filename)
end

deck    = json_file('deck.json')
cards   = json_file('cards.json')
layouts = json_file('layouts.json')
c = 0

Prawn::Document.generate('xclone-cards.pdf') do 
  grid = Gridder.new

  deck.each do |card, count|
    card = cards[card]
    layout = layouts[card['layout']]

    count.times do
      c += 1

      at_xy = grid.next.map &:in
      start_new_page if at_xy == [0, 1.in] && c > 1 

      stroke_rectangle at_xy, 1.in, 1.in

      margin = 2
      at_xy[0] += margin
      at_xy[1] -= margin

      params = { at: at_xy, width: 1.in - 2*margin, height: 1.in - 2*margin}
      card.each do |key, val|

        params.merge!  case layout[key]
          when nil      then next
          when 'nw'     then { valign: :top, align: :left }
          when 'n'      then { valign: :top, align: :center }
          when 'ne'     then { valign: :top, align: :right }
          when 'e'      then { valign: :center, align: :right }
          when 'se'     then { valign: :bottom, align: :right }
          when 's'      then { valign: :bottom, align: :center }
          when 'sw'     then { valign: :bottom, align: :left }
          when 'center' then { valign: :center, align: :center }
        end

      p val
      val = "[#{c}] #{val}" 
      text_box val.to_s, params

      end
    end
  end

end
