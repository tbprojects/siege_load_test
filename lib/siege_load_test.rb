class SiegeLoadTest
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :urls, :logs, :command, :mark, :output, :user, :time, :concurrent, :delay, :internet, :asynchronous

  USER_AGENT_PREFIX = "siege-load-test"
  DEFAULT_PARAMS = { :urls => [],
                     :user => nil,
                     :time => 60,
                     :concurrent => 15,
                     :delay => 1,
                     :internet => false,
                     :asynchronous => false }

  URL_FILE = "#{Rails.root.to_s}/log/siege_urls.txt"
  LOG_FILE = "#{Rails.root.to_s}/log/siege.log"
  TOKEN_FILE = "#{Rails.root.to_s}/vendor/plugins/siege_load_test/token"

  def initialize(options = {})
    set_params(DEFAULT_PARAMS)    
    set_params(options)
  end

  def perform
    create_log_file
    result = if valid_config?
      store_urls_in_file
      fetch_uniq_log_mark
      make_command
      if asynchronous
        Navvy::Job.enqueue(SiegeLoadTest, :perform_test, self)
      else
        SiegeLoadTest.perform_test(self)
      end
      self.logs = read_logs_for(mark)
      true
    else
      false
    end
    result
  end

  def add_url(url)
    urls << url if url.present?
  end

  def remove_url(url)
    urls.delete(url)
  end

  def set_params(options)
    DEFAULT_PARAMS.keys.each{|param| self.send("#{param}=", options[param.to_sym]) unless options[param.to_sym].nil?}
  end

  def performed?
    logs.present?
  end

  def persisted?
    false
  end

  def self.token
    token = `cat #{TOKEN_FILE}`
    "#{USER_AGENT_PREFIX}-#{token}"
  end

  def user_agent
    "#{self.class.token} #{user}"
  end

  def wait_to
    DateTime.now + (time.to_i + 5 + Navvy.configuration.sleep_time).seconds
  end  

  def self.find(mark)
    result = new
    log = `cat #{LOG_FILE} | grep "ID#{mark}!ID"`
    if log.present?
      result.send(:json_to_config, log.match(/JSON(.*)!JSON/)[1])
      result.send(:read_logs_for, mark)
      result.send(:make_command)
      result.mark = mark
      result
    end
  end

  def self.all
    log = `cat #{LOG_FILE}`
    log.scan(/ID([\w]+)!ID/).flatten.map{|id| find(id)}
  end

  def self.queued_jobs
    Navvy::Job.where(:object => "SiegeLoadTest")
  end
  
  private
  def self.perform_test(test)
    test.output = `#{test.command}`
    test.send :remove_urls_file
  end  

  def read_logs_for(mark)
    log = `cat #{LOG_FILE} | grep -A1 "ID#{mark}!ID" | sed -n 2p`.split(",")    
    self.logs = if log.present?
      {
        :date => log[0],
        :transactions => log[1].to_i,
        :availability => (log[8].to_f/(log[8].to_f+log[9].to_f)*100).to_f,
        :elapsed_time => log[2].to_f,
        :data_transferred => log[3].to_f,
        :response_time => log[4].to_f,
        :transaction_rate => log[5].to_f,
        :throughput => log[6].to_f,
        :concurrency => log[7].to_f,
        :successful_transactions => log[8].to_i,
        :failed_transactions => log[9].to_i
      }
    else
      {}
    end
  end  

  def make_command
      self.command =  %Q{siege --file='#{URL_FILE}' --log='#{LOG_FILE}' --user-agent='#{user_agent}' -m ID'#{mark}!ID JSON#{config_to_json}!JSON'}
      self.command += %Q{ -t#{time}S} if time
      self.command += %Q{ -c#{concurrent}} if concurrent
      self.command += %Q{ -d#{delay}} if delay
      self.command += %Q{ -i} if internet
  end

  def config_to_json
    result = {}
    DEFAULT_PARAMS.keys.each{|param| result[param] = self.send(param)}
    result.to_json
  end

  def json_to_config(json)
    self.set_params(JSON.parse(json).symbolize_keys!)
  end

  def store_urls_in_file
    self.urls ||= []
    File.open(URL_FILE, 'w') {|f| f.write(urls.join("\n")) }
  end

  def create_log_file
    File.open(LOG_FILE, 'w') {|f| f.write "" } unless File.file? LOG_FILE
  end

  def remove_urls_file
    `rm #{URL_FILE}`
  end

  def fetch_uniq_log_mark
    while !mark or `cat #{LOG_FILE} | grep "#{mark}"`.include?(mark) do
      self.mark = "#{rand(36**12).to_s(36)}"
    end
    mark
  end  

  def valid_config?
    errors.add(:urls, "No urls given") unless urls.present?
    errors.blank?
  end

  def self.generate_token    
    File.open(TOKEN_FILE, 'w') {|f| f.write(rand(36**8).to_s(36)) }    
  end
end