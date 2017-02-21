require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# A BIP Ruby client which, given a Plant Trial name, fetches:
#
#  * all Trait Scores (trait measurement values)
#  * all corresponding Trait Descriptors
#  * Line Names
#
# and produces a TSV to standard output, with each Plant Scoring Unit represented by a row.

if ARGV.size < 2
  STDERR.puts 'Not enough arguments. Usage:'
  STDERR.puts ' > ruby trial_analysis.rb plant_trial_name api_key'
  exit 1
end

@client = Net::HTTP.new('bip.earlham.ac.uk', 443)
@client.use_ssl = true
@headers = {
  'Content-Type' => 'application/json',
  'X-BIP-Api-Key' => ARGV[1]
}

def pluralize_class(class_name)
  class_name == 'plant_variety' ? 'plant_varieties' : "#{class_name}s"
end

def call_bip(request)
  response = @client.request(request)
  JSON.parse(response.body).tap{ |parsed| test_error(parsed) }
end

def test_error(response)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    exit 1
  end
end

outputs = {}

STDERR.puts '1. Finding the Plant Trial'

trial_encoded_name = URI.escape ARGV[0]
request = Net::HTTP::Get.new("/api/v1/plant_trials?plant_trial[query][plant_trial_name]=#{trial_encoded_name}", @headers)
response = call_bip request

if response['meta']['total_count'] == 0
  STDERR.puts "Plant Trial called #{trial_encoded_name} was not found. Exiting."
  exit 1
end

plant_trial_id = response['plant_trials'][0]['id']


STDERR.puts "  - Found, plant_trial_id = #{plant_trial_id}"


STDERR.puts '2. Loading all Trait Scores for this Plant Trial.'
STDERR.print '  - Progress: '

trait_scores = []
page = 1
loop do
  request = Net::HTTP::Get.new("/api/v1/trait_scores?trait_score[query][plant_scoring_units.plant_trial_id]=#{plant_trial_id}&page=#{page}&per_page=200", @headers)
  response = call_bip request
  break if response['trait_scores'].size == 0
  trait_scores += response['trait_scores']
  STDERR.print '.'
  page += 1
end

STDERR.puts "\n  - #{trait_scores.size} Trait Scores loaded"


STDERR.puts '3. Finding Trait Descriptors'

trait_descriptor_ids = trait_scores.map{ |ts| ts['trait_descriptor_id'] }.uniq
ids_param = trait_descriptor_ids.map{ |td_id| "trait_descriptor[query][id][]=#{td_id}" }.join("&")
request = Net::HTTP::Get.new("/api/v1/trait_descriptors?#{ids_param}", @headers)
response = call_bip request
trait_descriptors = response['trait_descriptors']

STDERR.puts "  - The Trait Descriptors scored in this Plant Trial: #{trait_descriptors.map{ |td| td['trait']['name'] }}"


STDERR.puts '4. Iterating through Plant Scoring Units'

plant_accession_ids = []
plant_scoring_units = []
page = 1
loop do
  request = Net::HTTP::Get.new("/api/v1/plant_scoring_units?plant_scoring_unit[query][plant_trials.id]=#{plant_trial_id}&page=#{page}&per_page=200", @headers)
  response = call_bip request
  break if response['plant_scoring_units'].size == 0
  response['plant_scoring_units'].each do |plant_scoring_unit|
    outputs[plant_scoring_unit['scoring_unit_name']] = {}
    outputs[plant_scoring_unit['scoring_unit_name']]['plant_accession_id'] = plant_scoring_unit['plant_accession_id']
    plant_accession_ids << plant_scoring_unit['plant_accession_id']
    outputs[plant_scoring_unit['scoring_unit_name']]['trait_scores'] =
      trait_scores.select{ |ts| ts['plant_scoring_unit_id'] == plant_scoring_unit['id']}
  end
  page += 1
  plant_scoring_units += response['plant_scoring_units']
end
plant_accession_ids.uniq!

STDERR.puts "Number of unique PA ids : #{plant_accession_ids.length}"


STDERR.puts '5. Finding Plant Accessions for this Plant Trial.'

plant_accessions = []
plant_accession_ids.each_slice(200) do |plant_accession_ids_slice|
  ids_pa_param = plant_accession_ids_slice.map{ |pa_id| "plant_accession[query][id][]=#{pa_id}" }.join("&")
  request = Net::HTTP::Get.new("/api/v1/plant_accessions?#{ids_pa_param}&per_page=200", @headers)
  response = call_bip request
  plant_accessions += response['plant_accessions']
  STDERR.print '.'
end

STDERR.puts "  - The Plant Accessions used in this Plant Trial: #{plant_accessions.map{ |pa| pa['plant_accession'] }.join(", ")}"
STDERR.puts "Number of Plant Accessions loaded: #{plant_accessions.size}"


STDERR.puts '6. Finding Plant Lines for this Plant Trial.'

plant_line_ids = plant_accessions.map{ |pa| pa['plant_line_id'] }.uniq
plant_lines = []
plant_line_ids.each_slice(200) do |plant_line_ids_slice|
  ids_pl_param = plant_line_ids_slice.map{ |pl_id| "plant_line[query][id][]=#{pl_id}" }.join("&")
  request = Net::HTTP::Get.new("/api/v1/plant_lines?#{ids_pl_param}&per_page=200", @headers)
  response = call_bip request
  plant_lines += response['plant_lines']
end

STDERR.puts "  - The Plant Lines used in this Plant Trial: #{plant_lines.map{ |pl| pl['plant_line_name'] }.join(", ")}"
STDERR.puts "Number of Plant Lines loaded: #{plant_lines.size}"


STDERR.puts "7. Linking Plant Accesions with Plant Scoring Units"

page = 1
loop do
  request = Net::HTTP::Get.new("/api/v1/plant_scoring_units?plant_scoring_unit[query][plant_trials.id]=#{plant_trial_id}&page=#{page}&per_page=200", @headers)
  response = call_bip request
  break if response['plant_scoring_units'].size == 0
  response['plant_scoring_units'].each do |plant_scoring_unit|
    outputs[plant_scoring_unit['scoring_unit_name']]['plant_accession'] = plant_accessions.detect { |pa| pa['id'] == plant_scoring_unit['plant_accession_id']}
  end
  page += 1
end


STDERR.puts '8. Generating output CSV to file Phenotypes.csv'
filename = "Phenotypes.csv"
 output_string = CSV.open(filename,'w') do |csv|
# output_string = CSV.generate(col_sep: "\t") do |csv|
  # NOTE: We do not want to use any quotes nor include whitespace characters except for column separators.
  trait_descriptor_names = trait_descriptors.map { |td| td['trait']['name'].gsub(/\s+/, '.') }

  # NOTE: The "<Trait>" column is expected by the tool taking this data as its input.
  csv << ["<Trait>","Seq_id"] + trait_descriptor_names

  outputs.
    select do |_, data|
      scored_trait_descriptors = trait_descriptors.select { |td|
        data['trait_scores'].detect { |ts| ts['trait_descriptor_id'] == td['id'] }
      }

      scored_trait_descriptors.count == trait_descriptors.count
    end.
    each do |scoring_unit_name, data|
      plant_accession = plant_accessions.detect{ |pa| pa['id'] == data['plant_accession_id'] }
      plant_line = plant_lines.detect{ |pl| pl['id'] == plant_accession['plant_line_id'] }

      unless plant_line
        STDERR.puts "No plant line information for #{scoring_unit_name} found. Exiting."
        exit(1)
      end

      csv << [plant_line['plant_line_name'], plant_line['sequence_identifier']] +
        trait_descriptors.map { |td|
          trait_score = data['trait_scores'].detect { |ts|
            ts['trait_descriptor_id'] == td['id']
          }
          trait_score['score_value'] if trait_score
        }
    end
end


STDERR.puts '9. Finished'
