module RandomData
  class Address
    attr_accessor :list

    def initialize
      shuffle_addresses
    end

    # Use random valid address for testing
    def generate
      shuffle_addresses if @list.empty?

      @list.pop[0]
    end

    def generate_with_lat_long
      shuffle_addresses if @list.empty?
      @list.pop
    end

    protected
    def shuffle_addresses
      @list = [
          ['30, Lourdes Heaven, 30th Rd, Bandra West, Pali Village, Bandra West, Mumbai, Maharashtra 400050, India', 19.062187, 72.829431],
          ['The Unicontinental, Nr. Khar Railway Station, 3rd Road, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400022, India', 19.070576, 72.839892],
          ['Summerville, 14th & 33rd Road, Ground Floor, Linking Road, Bandra West, Mumbai, Maharashtra 400050, India', 19.065561, 72.832342],
          ['2nd Floor, Kenilworth Mall, Phase 2, Off Linking Road, Behind KFC, Bandra West, Mumbai, Maharashtra 400050, India', 19.065534, 72.834020],
          ['Rohan Plaza, 5th Rd, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India', 19.068250, 72.838125],
          ['199, 4th Floor, VN Sphere Mall, Linking Road, Bandra West, Mumbai, Maharashtra 400050, India', 19.060098, 72.836302],
          ['3rd Floor, Link Square Mall, Linking Road, Above Global Fusion, Bandra West, Mumbai, Maharashtra 400050, India', 19.065108, 72.833765],
          ['2nd Floor, Shatranj Napoli, Off carter road, 12 Union Park, Khar West, Mumbai, Maharashtra 400052, India', 19.071718, 72.824874],
          ['Shubham Complex, Opposite ESIS Hospital, Akurli Road, Akurli Industry Estate, Kandivali East, Mumbai, Maharashtra 400101, India', 19.202220, 72.856290],
          ['Oberoi Chambers 1, Opposite Tanishq Showroom, Off New Link Road, Veera Desai Industrial Estate, Andheri West, Mumbai, Maharashtra 400053, India', 19.137065, 72.832584],
          ['759, 5th Ln, Ram Krishna Nagar, Khar West Ram Krishna Nagar, Khar West, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra, India', 19.068173, 72.837797],
          ['No. 500, Sant Kutir Apartments, Khar Linking Road, Behind Vijay, Sales Showroom, Khar, Bandra West, Mumbai, Maharashtra 400052, India', 19.066367, 72.833548],
          ['Plot 339, 16th Road, Bandra West, Pali Village, Bandra West, Mumbai, Maharashtra 400050, India', 19.063324, 72.829414],
          ['Ground Floor, Prabhat Kunj, 24th Road, Off Linking Road, Khar West, Bandra West, Mumbai, Maharashtra 400052, India', 19.066200, 72.833429],
          ['Shop No. 4, Mishra House, Chitrakar Dhurandhar Road, Ram Krishna Nagar, Khar West, Mumbai, Maharashtra 400052, India', 19.070777, 72.838772],
          ['No. 201, 202, Khan House, Hill Road, Above McDonald\'s, Bandra West, Sayed Wadi, Ranwar, Bandra West, Mumbai, Maharashtra 400050, India', 19.054623, 72.828249]
      ].shuffle
    end
  end
end

