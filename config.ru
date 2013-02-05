$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')

# config.ru
require 'heather_and_dennis'
run HeatherAndDennis::Server