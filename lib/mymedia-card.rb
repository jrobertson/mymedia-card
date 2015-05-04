#!/usr/bin/env ruby

# file: mymedia-card.rb

require 'mymedia'



class MyMediaCard < MyMedia::Base

  attr_reader :kvx
  
  def initialize(opt={}, media_type: 'kvx', public_type: 'kvx',
                                                    config: nil, prefix: 'k')
    
    @public_type = public_type
    super(media_type: media_type, public_type: public_type, config: config)
    @media_src = "%s/media/%s" % [@home, public_type]
    @target_ext = '.xml'
    @prefix = prefix
  end

  def copy_publish(filename, raw_msg='')

    src_path = File.join(@media_src, filename)
    raise "file not found : " + src_path unless File.exists? src_path

    file_publish(src_path, raw_msg) do |destination, raw_destination|

      if not raw_msg or raw_msg.empty? then        
        raw_msg = File.basename(src_path) + " updated: " + Time.now.to_s
      end

      if File.extname(src_path) == '.txt' then

        kvx, raw_msg = copy_edit(src_path, destination)
        copy_edit(src_path, raw_destination)

      else

        kvx = Kvx.new(src_path)
        title = kvx.summary[:title] || ''

        kvx.summary[:original_source] = File.basename(src_path)
        
        File.write destination, kvx.to_s

      end

      if not File.basename(src_path)[/#{@prefix}\d{6}T\d{4}\.txt/] then
        
        xml_filename = File.basename(src_path).sub(/txt$/,'xml')
        FileUtils.cp destination, @home + "/#{@public_type}/" + xml_filename
        
        if File.extname(src_path) == '.txt' then
          FileUtils.cp src_path, @home + "/#{public_type}/" + File.basename(src_path)
        end

        #publish the static links feed
        kvx_filepath = @home + "/#{@public_type}/static.xml"

        target_url = "%s/%s/%s" % [@website, @public_type, xml_filename]

        publish_dynarex(kvx_filepath, {title: xml_filename, url: target_url })
        
      end
      
      [raw_msg,target_url]
    end    

  end
  
  def copy_edit(src_path, destination, raw='')

    txt_destination = destination.sub(/xml$/,'txt')
    FileUtils.cp src_path, txt_destination        

    buffer = File.read(src_path)
    buffer2 = buffer.gsub(/\[[xX]\]/,'✓').gsub(/\[\s*\]/,'.')

    @kvx = Kvx.new(buffer2.strip)

    title = kvx.summary[:title]

    tags = if kvx.summary[:tags] then
      '#' + kvx.summary[:tags].split.join(' #') 
    else
      ''
    end
    
    raw_msg = ("%s %s" % [title, tags]).strip
        
    kvx.summary[:original_source] = File.basename(src_path)
    kvx.summary[:source] = File.basename(txt_destination)

    kvx.summary[:xslt] = @xsl unless kvx.item[:xslt]
    File.write destination, kvx.to_xml

    [kvx, raw_msg]
  end
  
end
