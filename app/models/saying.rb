class Saying < ActiveRecord::Base
  BURNS = [
    'You should rethink your life choices!',
    '. . . . . . . . . . . . . Who hired you?',
    'You Bastard!',
    pluck(:msg)
  ].flatten
end
