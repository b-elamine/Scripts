import json

# Sample OCR data as if returned by Tesseract OCR
ocr_data = {
    'text': ['SP', '95', 'E10', 'Sp', 'tha', 'E85', 'GAZOLE', 'GAZOLE', 'GPL', 'M49', '20'],
    'left': [10, 50, 90, 130, 170, 210, 250, 290, 330, 370, 410],
    'top': [10, 10, 10, 50, 50, 50, 90, 130, 170, 210, 250],
    'width': [30, 30, 30, 30, 30, 30, 50, 50, 30, 30, 30],
    'height': [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20],
    'block_num': [1, 1, 1, 2, 2, 2, 3, 4, 5, 6, 7],
    'par_num': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    'line_num': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
}

# Predefined fuel types in France
fuel_types = ["SP95E10", "SP98", "E85", "GAZOLE", "GPL"]

def combine_split_words(data):
    combined_data = []
    n = len(data['text'])
    
    i = 0
    while i < n:
        current_text = data['text'][i].strip().upper()
        left = data['left'][i]
        top = data['top'][i]
        width = data['width'][i]
        height = data['height'][i]

        combined_text = current_text

        # Initialize bounding box coordinates
        min_left = left
        max_right = left + width
        min_top = top
        max_bottom = top + height
        
        j = i + 1

        while j < n and data['line_num'][i] == data['line_num'][j]:
            next_text = data['text'][j].strip().upper()
            potential_combined_text = combined_text + next_text
            
            # Check if the potential combined text is a valid fuel type or a valid prefix of a fuel type
            if any(fuel.startswith(potential_combined_text) for fuel in fuel_types):
                combined_text = potential_combined_text
                min_left = min(min_left, data['left'][j])
                max_right = max(max_right, data['left'][j] + data['width'][j])
                min_top = min(min_top, data['top'][j])
                max_bottom = max(max_bottom, data['top'][j] + data['height'][j])
                j += 1
            else:
                break
        
        # Calculate combined width and height
        combined_width = max_right - min_left
        combined_height = max_bottom - min_top

        combined_data.append({
            'text': combined_text,
            'left': min_left,
            'top': min_top,
            'width': combined_width,
            'height': combined_height
        })
        
        i = j if combined_text != current_text else i + 1

    return combined_data

def filter_and_extract_labels(combined_data):
    extracted_labels = []
    for item in combined_data:
        text = item['text'].replace(' ', '').upper()
        if text in fuel_types:
            label_data = {
                "text": text,
                "bounding_box": {
                    "left": item['left'],
                    "top": item['top'],
                    "width": item['width'],
                    "height": item['height']
                }
            }
            extracted_labels.append(label_data)
    return extracted_labels

def pipeline(ocr_data):
    # Step 2: Combine Split Words
    combined_data = combine_split_words(ocr_data)
    print(f"Combined Data: {combined_data}")
    
    # Step 3: Text Filtering and Label Extraction
    labels = filter_and_extract_labels(combined_data)
    print(f"Extracted Labels: {labels}")
    
    # Step 4: Output the data
    output = {
        "labels": labels
    }
    
    return json.dumps(output, indent=4)

# Example usage
output = pipeline(ocr_data)
print("______________________________________________________________________________")
print(ocr_data)
print("______________________________________________________________________________")
print(output)
