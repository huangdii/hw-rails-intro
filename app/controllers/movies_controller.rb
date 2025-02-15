class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      sort = params[:sort] || session[:sort]
      case sort
        when 'title'
          ordering, @title_header = {:title => :asc}, 'hilite'
        when 'release_date'
          ordering, @date_header = {:release_date => :asc}, 'hilite'
      end
      @all_ratings = Movie.all_ratings
      @checked_ratings = params[:ratings] || session[:ratings]
      if @checked_ratings == nil
        ratings = Movie.all_ratings
        session[:ratings] = Movie.all_ratings
      else
        ratings = @checked_ratings.keys
        if (session[:sort] != params[:sort]) || (session[:ratings] != params[:ratings])
          session[:sort] = sort
          session[:ratings] = @checked_ratings
          redirect_to :sort => sort, :ratings => @checked_ratings 
          return
        end
      end
      @movies = Movie.order(ordering).where(rating: ratings)
      @check = ratings
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end