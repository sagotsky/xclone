#!/usr/bin/env ruby

require 'prawn'
require 'prawn/measurement_extensions'
require 'prawn/table'
require 'json'

class Gridder
  attr_accessor :x, :y, :grid

  def initialize(x, y)
    @x = x
    @y = y
    init_grid
  end

  def init_grid
    @grid = (0..@x).to_a.product( (1..@y).to_a )
  end

  def next
    @grid.empty? ? (init_grid ; nil) : @grid.pop
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
  grid = Gridder.new 6, 10

  deck.each do |card, count|
    card = cards[card]
    layout = layouts[card['layout']]

    count.times do

      at_xy = grid.next
      if at_xy.nil?
        start_new_page
        at_xy = grid.next
      end
      at_xy = at_xy.map &:in


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

      text_box val.to_s, params
      end
    end
  end

end
