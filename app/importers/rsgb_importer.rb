class RsgbImporter
  COORDS = [[54.47, -4.22],
            [55.86, -4.25],
            [54.89, -2.93],
            [53.48, -2.24],
            [51.62, -3.94],
            [50.11, -5.53],
            [51.42, -1.72],
            [52.05, -1.14]]
  
  ENDPOINT = -> (lat, lng) { "https://thersgb.org/services/clubfinder/phpsqlsearch_genxml.php?lat=#{lat}&lng=#{lng}&radius=100" }

  CALLSIGN_RE = /(?<reg>[UDJIMWPTHNSC]?)(?<callsign>M\g<reg>[01356][A-Z]{3})|(?<callsign>(G\g<reg>[123468][A-Z]{2,3})|(G\g<reg>[07][A-Z]{3})|(G\g<reg>5[A-Z]{2}))|(?<callsign>2[EUDJIMW][01][A-Z]{3})/

  EMAIL_RE = /\S+@\S+/
  
  def import
    each_marker(&import_record)
  end

  def test
    each_marker { |m| print_record(m) }
  end

  def each_marker(&blk)
    COORDS.each do |lat, lng|
      curl = Curl::Easy.perform(ENDPOINT.(lat, lng))
      Oga.parse_xml(curl.body_str).xpath('//marker').each(&blk)
    end
  end

  def import_record(marker)
    create_or_update(marker.attribute('clubcall').value, &update_proc)
  end

  def print_record(marker)
    club = Club.new
    update_proc(marker, club)
    pp club.as_json
  end

  def update_proc(marker, club)
    club.iaru_region = 1
    club.country = 'United Kingdom'
    club.name = marker.attribute('clubname').value
    
    contact = marker.attribute('contact').value
    club.contact_person = extract_contact_person(contact)
    club.contact_callsign = extract_contact_callsign(contact)
    club.contact_email = extract_contact_email(contact)

    if tel = marker.attribute('tel').value
      club.phone = GlobalPhone.parse(tel, :gb).normalize
    end

    club.location = [marker.attribute('lat').value, marker.attribute('lng').value]
  end

  def extract_contact_person(string)
    name = string
    if callsign = extract_contact_callsign(name)
      name = name.split(callsign).first.strip
    end
    if email = extract_contact_email(name)
      name = name.gsub(email, '').strip
    end
    if name.include?(',')
      name = name.split(',').first.strip
    end
    name
  end

  def extract_contact_callsign(string)
    has_callsign?(string).try(:[], :callsign)
  end

  def extract_contact_email(string)
    has_email?(string).try(:[], 1)
  end

  def has_callsign?(string)
    CALLSIGN_RE.match(string)
  end

  def has_email?(string)
    EMAIL_RE.match(string)
  end
end
