class PagesController < ApplicationController
  def index #views/index.html.erbを表示させるというアクション
    @users = User.all
  end

  def search
    if params[:search].present?

      if params["lat"].present? & params["lng"].present?
        @latitude = params["lat"]
        @longitude = params["lng"]

        geolocation = [@latitude,@longitude]
      else
        geolocation = Geocoder.coordinates(params[:search])
        @latitude = geolocation[0]
        @longitude = geolocation[1]
      end

      @listings = Listing.where(active: true).near(geolocation, 1, order: 'distance')

      # 検索欄が空欄の場合
    else

      @listings = Listing.where(active: true).all
      @latitude = @listings.to_a[0].latitude
      @longitude = @listings.to_a[0].longitude

    end

    #リスティングデータを配列にしてまとめる
    @arrlistings = @listings.to_a

    # start_date end_dateの間に予約がないことを確認.あれば削除
    if ( !params[:start_date].blank? && !params[:end_date].blank? )

      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      @listings.each do |listing|

        # check the listing is availble between start_date to end_date
        unavailable = listing.reservations.where(
            "(? <= start_date AND start_date <= ?)
              OR (? <= end_date AND end_date <= ?)
              OR (start_date < ? AND ? < end_date)",
            start_date, end_date,
            start_date, end_date,
            start_date, end_date
        ).limit(1)

        # delete unavailable room from @listings
        if unavailable.length > 0
          @arrlistings.delete(listing)
        end
      end
    end
  end

  def ajaxsearch

    # まずajaxで送られてきた緯度経度をセッションに入れる
    if !params[:geolocation].blank?
      geolocation = params[:geolocation]
    end

    @listings = Listing.where(active: true).near(geolocation, 1, order: 'distance')

    #リスティングデータを配列にしてまとめる
    @arrlistings = @listings.to_a

    # start_date end_dateの間に予約がないことを確認.あれば削除
    if ( !params[:start_date].blank? && !params[:end_date].blank? )

      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      @listings.each do |listing|

        # check the listing is availble between start_date to end_date
        unavailable = listing.reservations.where(
            "(? <= start_date AND start_date <= ?)
              OR (? <= end_date AND end_date <= ?)
              OR (start_date < ? AND ? < end_date)",
            start_date, end_date,
            start_date, end_date,
            start_date, end_date
        ).limit(1)

        # delete unavailable room from @listings
        if unavailable.length > 0
          @arrlistings.delete(listing)
        end
      end
    end

    respond_to :js

  end
end
