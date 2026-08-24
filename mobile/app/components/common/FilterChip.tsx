import React from 'react';
import { TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons as Icon } from '@expo/vector-icons';
import { Text } from '../../theme/restyle';
import { useTheme } from '@shopify/restyle';
import { Theme } from '../../theme/theme';

interface FilterChipProps {
  label: string;
  isSelected: boolean;
  onPress: () => void;
  icon?: keyof typeof Icon.glyphMap;
  style?: any;
}

export const FilterChip: React.FC<FilterChipProps> = ({ label, isSelected, onPress, icon, style }) => {
  const theme = useTheme<Theme>();
  
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.7}
      style={[
        {
          paddingHorizontal: 16,
          paddingVertical: 8,
          borderRadius: 20,
          backgroundColor: isSelected ? theme.colors.primary : theme.colors.primaryBg,
          marginRight: 8,
          borderWidth: 1,
          borderColor: isSelected ? theme.colors.primary : theme.colors.border,
          flexDirection: 'row',
          alignItems: 'center'
        },
        style
      ]}
    >
      {icon && (
        <Icon 
          name={icon as any} 
          size={14} 
          color={isSelected ? 'white' : theme.colors.primary} 
          style={{ marginRight: 4 }} 
        />
      )}
      <Text
        fontSize={12}
        fontWeight={isSelected ? '800' : '600'}
        color={isSelected ? 'white' : 'primary'}
      >
        {label}
      </Text>
    </TouchableOpacity>
  );
};
