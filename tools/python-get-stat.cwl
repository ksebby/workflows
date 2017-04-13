#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
- $import: ./metadata/envvar-global.yml
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - var default_output_filename = function() {
        return inputs.bowtie_log.location.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')+".stat";
    };

hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/scidap:v0.0.2
  dockerFile: >
    $import: ./dockerfiles/scidap-Dockerfile

inputs:

  script:
    type: string?
    default: |
      #!/usr/bin/env python
      import sys, re
      TOTAL, ALIGNED, SUPRESSED, USED = 100, 80, 0, 0
      with open(sys.argv[1], 'r') as bowtie_log:
        for line in bowtie_log:
          if 'processed:' in line:
            TOTAL = int(line.split('processed:')[1])
          if 'alignment:' in line:
            ALIGNED = int(line.split('alignment:')[1].split()[0])
          if 'due to -m:' in line:
            SUPRESSED = int(line.split('due to -m:')[1].split()[0])
      USED = ALIGNED
      with open(sys.argv[2], 'r') as rmdup_log:
        for line in rmdup_log:
          if '/' in line and 'Skip' not in line:
            splt = line.split('/')
            USED = int((splt[1].split('='))[0].strip()) - int((splt[0].split(']'))[1].strip())
      print TOTAL, ALIGNED, SUPRESSED, USED
    inputBinding:
      position: 5
    doc: |
      Python script to get TOTAL, ALIGNED, SUPRESSED, USED

  bowtie_log:
    type: File
    inputBinding:
      position: 6
    doc: |
      Log file from Bowtie

  rmdup_log:
    type: File
    inputBinding:
      position: 7
    doc: |
      Log file from samtools rmdup

outputs:

  output:
    type: File
    outputBinding:
      glob: $(default_output_filename())


baseCommand: [python, '-c']
arguments:
  - valueFrom: $(" > " + default_output_filename())
    position: 100000
    shellQuote: false

$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/docs/schema_org_rdfa.html

s:name: "python-get-stat"
s:downloadUrl: https://raw.githubusercontent.com/SciDAP/workflows/master/tools/python-get-stat.cwl
s:codeRepository: https://github.com/SciDAP/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:michael.kotliar@cchmc.org
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898

doc: |
  Tool to process log files from Bowtie aligner and samtools rmdup.

s:about: >
  Runs python code from the script input
