class Saying < ActiveRecord::Base
  BURNS = [
    'You should rethink your life choices!',
    '. . . . . . . . . . . . . Who hired you?',
    Saying.pluck(:msg).map{|f| ". . . . . . . . . . . . . #{f}"}
  ].flatten
end
