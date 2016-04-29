class ClubsController < ApplicationController
  def index
    run ClubsSearch
  end

  def show
    run ClubsShow
  end
end
