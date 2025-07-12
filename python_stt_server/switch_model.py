#!/usr/bin/env python3
"""
Utility script to switch between different Whisper models.
Usage: python switch_model.py [model_name]
Available models: tiny, base, small, medium, large, large-v3
"""

import sys
import os

def update_config(model_name):
    """Update the config.py file with the specified model name."""
    config_path = os.path.join(os.path.dirname(__file__), 'config.py')
    
    # Read current config
    with open(config_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Update MODEL_NAME
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if line.strip().startswith('MODEL_NAME ='):
            lines[i] = f'MODEL_NAME = "{model_name}"  # Changed via switch_model.py'
            break
    
    # Write updated config
    with open(config_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    
    print(f"✓ Model switched to '{model_name}'")
    print(f"✓ Updated {config_path}")

def main():
    available_models = ['tiny', 'base', 'small', 'medium', 'large', 'large-v3']
    
    if len(sys.argv) != 2:
        print("Usage: python switch_model.py [model_name]")
        print(f"Available models: {', '.join(available_models)}")
        print("\nModel sizes:")
        print("- tiny: ~39MB (fastest, least accurate)")
        print("- base: ~74MB (fast, good accuracy)")
        print("- small: ~244MB (balanced)")
        print("- medium: ~769MB (better accuracy)")
        print("- large: ~1550MB (high accuracy)")
        print("- large-v3: ~1550MB (best accuracy)")
        sys.exit(1)
    
    model_name = sys.argv[1].lower()
    
    if model_name not in available_models:
        print(f"Error: '{model_name}' is not a valid model name")
        print(f"Available models: {', '.join(available_models)}")
        sys.exit(1)
    
    update_config(model_name)

if __name__ == "__main__":
    main() 