import React from 'react';
import { TouchableOpacity, Platform } from 'react-native';
import { Ionicons as Icon } from '@expo/vector-icons';
import { Box, Text } from '../../theme/restyle';
import { useTheme } from '@shopify/restyle';
import { Theme } from '../../theme/theme';
import StatusBadge from './StatusBadge';

interface SinistreCardProps {
  item: any;
  onPress: (item: any) => void;
  formatDate: (dateStr: string) => string;
}

export const SinistreCard: React.FC<SinistreCardProps> = ({ item, onPress, formatDate }) => {
  const theme = useTheme<Theme>();

  return (
    <TouchableOpacity activeOpacity={0.8} onPress={() => onPress(item)}>
      <Box
        backgroundColor="cardBackground"
        marginHorizontal="m"
        marginVertical="s"
        borderRadius="l"
        padding="l"
        borderWidth={1}
        borderColor="borderLight"
        style={Platform.select({
          ios: { shadowColor: theme.colors.primary, shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 12 },
          android: { elevation: 3 },
          web: { boxShadow: `0 4px 12px ${theme.colors.border}` as any }
        })}
      >
        {/* Header: Branche + Status */}
        <Box flexDirection="row" justifyContent="space-between" alignItems="center" marginBottom="m">
          <Box flexDirection="row" alignItems="center">
            <Box backgroundColor="errorBg" padding="s" borderRadius="m" marginRight="s">
              <Icon name="warning" size={18} color={theme.colors.error} />
            </Box>
            <Text variant="caption" color="error" fontWeight="800" style={{ letterSpacing: 1, textTransform: 'uppercase' }}>
              {item.branche || '-'}
            </Text>
          </Box>
          <StatusBadge label={item.statut || 'En cours'} variant={item.statut_variant || 'warning'} />
        </Box>

        {/* Sinistre Number */}
        <Box marginBottom="m">
          <Text variant="caption" color="textTertiary" marginBottom="xxs">N° de sinistre</Text>
          <Text variant="title" fontWeight="900" fontSize={20} color="text">
            {item.numero || item.num_sinistre || item.sinistre || '-'}
          </Text>
        </Box>

        <Box height={1} backgroundColor="borderLight" marginBottom="m" />

        {/* Details Grid */}
        <Box flexDirection="row" justifyContent="space-between">
          <Box flex={1} marginRight="m">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="document-text-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Police liée</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text">
              {item.police || '-'}
            </Text>
          </Box>

          <Box alignItems="flex-end">
            <Box flexDirection="row" alignItems="center" marginBottom="xxs">
              <Icon name="calendar-outline" size={14} color={theme.colors.textTertiary} style={{ marginRight: 4 }} />
              <Text variant="caption" color="textTertiary">Date de survenance</Text>
            </Box>
            <Text variant="bodySmall" fontWeight="700" color="text">
              {formatDate(item.date || item.dateSurvenance || item.date_survenance)}
            </Text>
          </Box>
        </Box>
      </Box>
    </TouchableOpacity>
  );
};
